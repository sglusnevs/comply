
source incl/functions.sh

echo_log 'INFO' 'Gathering Chrony NTP Client Settings (2.2.1.2)...'

# prevent '*' sign expansion
set -f

LOCATION=/etc/chrony.conf

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Chrony NTP Client Config (2.2.1.2)" Location="$LOCATION" Type="TXT">
EOS1

grep -v '^$\|^\s*\#' $LOCATION | grep server | while read -r LINE; do
    entry_cdata "$LINE"
done 

cat <<-EOS2
    </ConfigData>
EOS2
