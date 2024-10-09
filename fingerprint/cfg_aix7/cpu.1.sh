
source incl/functions.sh

echo_log 'INFO' 'Gathering CPU info...'

cat <<-EOS1
    <Processor>
      <Name>
EOS1

export IFS=:

prtconf  | while read -r K V; do
    V=$(chomp $V)
    case $K in
        'Processor Type')
            section 9 'Description' $V
        ;;
        'System Model')
            section 9 'Manufacturer' `echo $V | cut -d,  -f 1`
        ;;
        'Processor Implementation Mode')
            section 9 'Family' `echo $V | cut -d ' ' -f 2`
        ;;
        'Processor Clock Speed')
            section 9 'CurrentClockSpeed' `echo $V | cut -d ' ' -f 1`
        ;;
        'CPU Type')
            section 9 'Architecture' `echo $V | cut -d ' ' -f 1`
        ;;
        *)
        ;;
    esac
done 

cat <<-EOS2
      </Name>
    </Processor>
EOS2
