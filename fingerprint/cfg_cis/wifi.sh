
source incl/functions.sh

REFMOD=$(basename $BASH_SOURCE | sed -e 's/\.sh$//')

echo_log 'INFO' 'Gathering WiFi settings...'

# prevent '*' sign expansion
set -f

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="WiFi settings" Location="nmcli radio all" Type="TXT">
EOS1

    nmcli radio all | while read -r LINE; do
        entry_cdata "$LINE"
    done


cat <<-EOS2
    </ConfigData>
EOS2

