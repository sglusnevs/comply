
source incl/functions.sh

echo_log 'INFO' 'Gathering access settings...'

REFMOD=$(basename $BASH_SOURCE | sed -e 's/\.sh$//')

# prevent '*' sign expansion
set -f

LOCATION=/etc/security/access.conf

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Access Config" Location="$LOCATION" Type="TXT">
EOS1

grep -v '^$\|^\s*\#' $LOCATION | while read -r LINE; do
    entry_cdata "$LINE"
done 

cat <<-EOS2
    </ConfigData>
EOS2
