
source incl/functions.sh

echo_log 'INFO' 'Gathering rsyslog settings...'

MAIN_CONFIG='/etc/rsyslog.conf /etc/rsyslog.d/*.conf'

# main config 

ls $MAIN_CONFIG | while read FILENAME; do 

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="$FILENAME rsyslog Config" Location="$FILENAME" Type="TXT">
EOS1

grep -E -v '^$|^\s*\#|^\s*;' $FILENAME | while read LINE; do
    entry_cdata $LINE
done 

cat <<-EOS2
    </ConfigData>
EOS2

done

