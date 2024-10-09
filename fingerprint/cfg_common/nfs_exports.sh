
source incl/functions.sh

LOCATION=/etc/exports

echo_log 'INFO' 'Gathering $LOCATION...'

# prevent '*' sign expansion
set -f

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="NFS Exports" Location="$LOCATION" Type="TXT">
EOS1

grep -v '^$' $LOCATION | grep -v '^#' | while read -r LINE; do
    entry_cdata "$LINE"
done 

cat <<-EOS2
    </ConfigData>
EOS2
