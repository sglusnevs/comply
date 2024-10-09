
source incl/functions.sh

echo_log 'INFO' 'Gathering network interfaces settings...'

cat <<-EOS1
    <Network>
EOS1


IDX=0
# note: 'getline' in awk just means 'read next line as well'

ifconfig -a | awk '/flags=/ {printf "%s", $1; getline; print $0}' | while read -r LINE; do
    echo_log 'DEBUG' "Network data line read: '$LINE'"
    IDX=$((IDX+1))
    TOKENS=($LINE)
    IF_NAME=`echo ${TOKENS[0]} | sed -e 's/://'`
    IF_TYPE=${TOKENS[1]}

    echo_log 'DEBUG' "Network interface $IF_NAME of type $IF_TYPE found"

    if [ "$IF_TYPE" = 'inet' ]; then
        IF_ADDR=${TOKENS[2]}
        IF_SUBNET_BITS=${TOKENS[4]}
        IF_SUBNET_MASK=`cidr2mask $(hex2cidr $IF_SUBNET_BITS)`
    elif [ "$IF_TYPE" = 'inet6' ]; then
        INFO_ADDR=${TOKENS[2]}
        echo_log 'DEBUG' "Network address data line read: '$INFO_ADDR'"
        TOKENS_ADDR=(`echo ${INFO_ADDR} | awk -F/ '{ print $1, $2}'`)
        echo_log 'DEBUG' "Network address tokens: '$TOKENS_ADDR'"
        IF_ADDR=${TOKENS_ADDR[0]}
        IF_SUBNET_BITS=${TOKENS_ADDR[1]}
        IF_SUBNET_MASK="$IF_SUBNET_BITS"
    fi


    # do not explore MAC adddresses of non-ethernet interfaces
    IF_MACADDR=`quotemeta $(ifconfig "$IF_NAME" | grep ether | cut -d' ' -f 2)`

    echo_log 'DEBUG' "Network interface '$IF_NAME' has IP '$IF_ADDR' subnet bits '$IF_SUBNET_BITS' subnet mask '$IF_SUBNET_MASK' macaddr '$IF_MACADDR'"
    tag 6 `printf '<Interface Description="%s" InterfaceIndex="%d" MACAddress="%s" IPEnabled="1">' "$IF_NAME" "$IDX" "$IF_MACADDR"`
    tag 8 `printf '<IPAddress>%s</IPAddress>' "$IF_ADDR"`
    tag 8 `printf '<IPSubnet>%s</IPSubnet>' "$IF_SUBNET_MASK"`
    tag 6 '</Interface>'
done 

cat <<-EOS2
    </Network>
EOS2
