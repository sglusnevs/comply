
source incl/functions.sh

echo_log 'INFO' 'Gathering crontab entries...'

find /etc/cron.* /var/spool/cron/root -type f ! -name cron.deny | while read FILENAME; do 

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Crontab" Location="$FILENAME" Type="TXT">
EOS1

/usr/xpg4/bin/grep -E -v '^$|^\s*\#|^\s*;' $FILENAME | while read LINE; do
    # prevent '*' sign expansion
    set -f
    entry_cdata $LINE
done 

cat <<-EOS2
    </ConfigData>
EOS2

done


cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Crontab" Location="/etc/crontab" Type="INI" ElementDelimiter="=">
EOS1

/usr/xpg4/bin/grep -E -v '^$|^\s*\#|^\s*;' /etc/crontab | while IFS="=" read K V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done

cat <<-EOS2
    </ConfigData>
EOS2

