
source incl/functions.sh

echo_log 'INFO' 'Gathering SUDO settings...'

# prevent '*' sign expansion
set -f

LOCATION=/etc/sudo.conf

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="SUDO Config" Location="$LOCATION" Type="TXT">
EOS1

grep -v '^$\|^\s*\#' $LOCATION | while read -r LINE; do
    entry_cdata "$LINE"
done 

cat <<-EOS2
    </ConfigData>
EOS2
