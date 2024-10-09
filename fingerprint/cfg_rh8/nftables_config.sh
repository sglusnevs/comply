
source incl/functions.sh

echo_log 'INFO' 'Gathering nftables config...'

BASEDIR='/etc/nftables'

MAIN_CONFIG=/etc/sysconfig/nftables.conf

# prevent '*' sign expansion
set -f

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Standalone nftables Config" Location="$MAIN_CONFIG" Type="TXT">
EOS1

DATA=`grep -E -v '^$|^\s*\#|^\s*;' $MAIN_CONFIG `

while read -r LINE; do
    entry_cdata "$LINE"
done <<< "$DATA"

cat <<-EOS2
    </ConfigData>
EOS2

ls $BASEDIR | while read CFG_FILE; do 

FILENAME="$BASEDIR/$CFG_FILE"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="$CFG_FILE standalone limits Config" Location="$FILENAME" Type="TXT">
EOS1

grep -E -v '^$|^\s*\#|^\s*;' $FILENAME | while read LINE; do
    entry_cdata "$LINE"
done 

cat <<-EOS2
    </ConfigData>
EOS2

done
