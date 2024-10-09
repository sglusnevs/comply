
source incl/functions.sh

echo_log 'INFO' 'Gathering System Banners...'

MAIN_CONFIG='/etc/motd /etc/issue /etc/issue.net'

ls $MAIN_CONFIG | while read FILENAME; do 

if [ ! -f $FILENAME ]; then
    continue
fi

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="$FILENAME Banner Config" Location="$FILENAME" Type="TXT">
EOS1

cat $FILENAME | while read LINE; do
    entry_cdata $LINE
done 

cat <<-EOS2
    </ConfigData>
EOS2

done
