
source incl/functions.sh

echo_log 'INFO' 'Gathering iptables rules...'

# prevent '*' sign expansion
set -f

cat <<-EOS1
    <ConfigData Label="Iptables Rules" Location="iptables-save" Type="TXT">
EOS1

    iptables-save | while read -r LINE; do
        entry_cdata "$LINE"
    done


cat <<-EOS2
    </ConfigData>
EOS2
