
source incl/functions.sh

echo_log 'INFO' 'Gathering CPU info...'

cat <<-EOS1
    <Processor>
EOS1

# We need to count lines issued by `prtdiag` after "Processor Sockets" 
# to get to actual CPU data:
#
# ==== Processor Sockets ====================================
#
# Version                          Location Tag
# -------------------------------- --------------------------
# Intel(R) Core(TM) i5-6200U CPU @ 2.30GHz CPU #000
# 

ARCHITECTURE=`chomp $(uname -p)`

LINES_CNT=0
CPU_CNT=0
CPU_INFO=''
DATA=`prtdiag`
while read -r LINE; do
    LINE=$(chomp $LINE)
    echo_log 'DEBUG' "Processing CPU info line '$LINE'"
    if [[ "$LINE" =~ (Processor Sockets|Virtual CPUs)  ]]; then
            LINES_CNT=1
            echo_log 'DEBUG' "Found line $LINES_CNT of CPU info: '$LINE'"
    elif [[ -z "$LINE" && "$LINES_CNT" -eq 1 ]]; then
            LINES_CNT=2
            echo_log 'DEBUG' "Found line $LINES_CNT of CPU info: '$LINE'"
    elif [[ "$LINE" =~ ^Version|CPU && "$LINES_CNT" -eq 2 ]]; then
            LINES_CNT=3
            echo_log 'DEBUG' "Found line $LINES_CNT of CPU info: '$LINE'"
    elif [[ "$LINE" =~ ^--- && "$LINES_CNT" -eq 3 ]]; then
            LINES_CNT=4
            echo_log 'DEBUG' "Found line $LINES_CNT of CPU info: '$LINE'"
    elif [[ -z "$LINE" && "$LINES_CNT" -eq 4 ]]; then
            # empty line after CPU info, stop processing
            echo_log 'DEBUG' "BREAK"
            break
    elif [[ "$LINES_CNT" -eq 4 ]]; then
            CPU_CNT=$((CPU_CNT+1))
            echo_log 'DEBUG' "Found actual CPU line of CPU info: '$LINE'"
            echo_log 'DEBUG' "CPUs detected so far: '$CPU_CNT'"
            tag 9 '<Name>'
            # Parse CPU line into seprate sections
            CPU=($LINE)
            if [[ "$ARCHITECTURE" = 'sparc' ]]; then
		section 13 'Description' "${LINE[@]:1}"
                section 13 'Manufacturer' 'Oracle'
                section 13 'Architecture' $ARCHITECTURE
                section 13 'Family' ${CPU[3]}
                section 13 'CurrentClockSpeed' ${CPU[1]}
            else
		section 13 'Description' "$LINE"
                section 13 'Manufacturer' 'Oracle'
                section 13 'Architecture' $ARCHITECTURE
                section 13 'Family' ${CPU[2]}
                section 13 'CurrentClockSpeed' ${CPU[5]}
            fi
            tag 9 '</Name>'
            CPU_INFO=$LINE
    fi
done <<< "$DATA"

cat <<-EOS2
    </Processor>
EOS2
