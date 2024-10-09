
source incl/functions.sh

echo_log 'INFO' 'Gathering CPU info...'

# delimit fields in 'while' loop with ':'
# because lscpu separates fields with ':'
IFS=:
CPUS=1

DATA=`lscpu`

while read -r K V; do
    V=$(quotemeta `chomp $V`)
    echo_log 'DEBUG' "Parsing CPU info line '$K' => '$V'"
    case $K in
        'Model name')
            DESCRIPTION="$V"
            echo_log 'DEBUG' "Description found: '$V'"
        ;;
        'Vendor ID')
            MANUFACTURER="$V"
            echo_log 'DEBUG' "Manufacturer found: '$V'"
        ;;
        'CPU family')
            FAMILY="$V"
            echo_log 'DEBUG' "CPU family found: '$V'"
        ;;
        'CPU MHz')
            SPEED="$V"
            echo_log 'DEBUG' "CPU speed found: '$V'"
        ;;
        'Architecture')
            ARCH="$V"
            echo_log 'DEBUG' "CPU architecture found: '$V'"
        ;;
        'Stepping')
            STEPPING="$V"
            echo_log 'DEBUG' "CPU stepping found: '$V'"
        ;;
        'L2 cache')
            L2CACHE="$V"
            echo_log 'DEBUG' "CPU L2 cache found: '$V'"
        ;;
        'CPU(s)')
            CPUS="$V"
            echo_log 'DEBUG' "Number of CPUs found: '$V'"
        ;;
        *)
        ;;
    esac
done  <<< "$DATA"

echo_log 'DEBUG' "Finally: number of CPUs found: '$CPUS'"

tag 4 '<Processor>'

# I set -s: for seq as separator because we set IFS to : earlier
for N in $(seq -s: $CPUS); do

    echo_log 'DEBUG' "Dumping CPU #$N"

	# WARNING: use tabs on lines with 'EOS', not spaces!!!
	cat <<-EOS
        <Name>
            <Description>$DESCRIPTION</Description>
            <Manufacturer>$MANUFACTURER</Manufacturer>
            <Family>$FAMILY</Family>
            <CurrentClockSpeed>$SPEED</CurrentClockSpeed>
            <Architecture>$ARCH</Architecture>
            <Stepping>$STEPPING</Stepping>
            <L2CacheSize>$STEPPING</L2CacheSize>
        </Name>
	EOS
done

tag 4 '</Processor>'
