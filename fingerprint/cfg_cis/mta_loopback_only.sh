
source incl/functions.sh

echo_log 'INFO' 'Gathering mail transfer agent listening interfaces...'

REFMOD=$(basename $BASH_SOURCE | sed -e 's/\.sh$//')

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="MTA port 25 non-loopback listening interfaces" Location="ss -lntu" Type="TXT">
EOS1

ss -lntu | grep -E ':25\s' | grep -E -v '\s(127.0.0.1|::1):25\s'| while read LINE; do
    entry_cdata $LINE
done 

cat <<-EOS2
    </ConfigData>
EOS2

