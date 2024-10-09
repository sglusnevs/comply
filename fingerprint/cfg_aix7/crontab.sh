
source incl/functions.sh

echo_log 'INFO' 'Gathering crontab entries...'

find /var/adm/cron.* /var/spool/cron/crontabs/root -type f ! -name cron.deny | while read FILENAME; do 

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Crontab" Location="$FILENAME" Type="TXT">
EOS1

grep -E -v '^$|^\s*\#|^\s*;' $FILENAME | while read LINE; do
    # prevent '*' sign expansion
    set -f
    entry_cdata $LINE
done 

cat <<-EOS2
    </ConfigData>
EOS2

done

