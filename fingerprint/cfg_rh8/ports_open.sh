
source incl/functions.sh

echo_log 'INFO' 'Gathering information about open ports...'

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Open Ports" Location="ss -4tuln" Type="TXT">
EOS1

ss -4tuln | while read LINE; do
    entry_cdata $LINE
done 

cat <<-EOS2
    </ConfigData>
EOS2

