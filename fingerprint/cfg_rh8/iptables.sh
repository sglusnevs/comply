
source incl/functions.sh

echo_log 'INFO' 'Gathering iptables rules...'

# prevent '*' sign expansion
set -f

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Iptables IPv4 Rules" Location="iptables -L -n -v" Type="TXT">
EOS1

    iptables -L -n -v | while read -r LINE; do
        entry_cdata "$LINE"
    done


cat <<-EOS2
    </ConfigData>
EOS2

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Iptables IPv6 Rules" Location="ip6tables -L -n -v" Type="TXT">
EOS1

    ip6tables -L -n -v | while read -r LINE; do
        entry_cdata "$LINE"
    done


cat <<-EOS2
    </ConfigData>
EOS2
