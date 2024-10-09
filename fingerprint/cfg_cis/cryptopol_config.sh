
source incl/functions.sh

echo_log 'INFO' 'Gathering Crypto Policies...'

MAIN_CONFIG='/etc/crypto-policies/config'

ls $MAIN_CONFIG | while read FILENAME; do 

if [ ! -f $FILENAME ]; then
    continue
fi

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="$FILENAME Crypto Policy Config" Location="$FILENAME" Type="TXT">
EOS1

grep -E -v '^$|^\s*\#|^\s*;' $FILENAME | while read LINE; do
    entry_cdata $LINE
done 

cat <<-EOS2
    </ConfigData>
EOS2

done
