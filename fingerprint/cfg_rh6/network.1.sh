
source incl/functions.sh

echo_log 'INFO' 'Gathering network interfaces settings...'

cat <<-EOS1
    <Network>
EOS1


IDX=0
ip -o a | awk '/scope/ {print $2, $3, $4}' | while read -r NAME FAM IPR; do
    IDX=$((IDX+1))
    echo $IPR |  awk -F/ '{print $1, $2}'  | while read IP CIDR; do 
        MAC=`exec_cmd cat /sys/class/net/$NAME/address`
        tag 6 `printf '<Interface Description="%s" InterfaceIndex="%d" MACAddress="%s" IPEnabled="1">' $NAME $IDX $MAC`
        tag 8 `printf '<IPAddress>%s</IPAddress>' $IP`
        if [[ "$FAM" = 'inet6' ]]; then
            MASK="$CIDR"
        else
            MASK=`cidr2mask $CIDR`
        fi
        tag 8 `printf '<IPSubnet>%s</IPSubnet>' $MASK`
        tag 6 '</Interface>'
    done
done 

cat <<-EOS2
    </Network>
EOS2
