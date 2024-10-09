
source incl/functions.sh

echo_log 'INFO' 'Gathering auditd settings...'

MAIN_CONFIG='/etc/audit/auditd.conf'
DIR_CONFIG='/etc/audit/rules.d/*.rules'

# main config 

ls $MAIN_CONFIG | while read FILENAME; do 

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="$FILENAME auditd Config" Location="$FILENAME" Type="INI" ElementDelimiter="=">
EOS1

grep -E -v '^$|^\s*\#|^\s*;' $FILENAME | while IFS='=' read K V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done 

cat <<-EOS2
    </ConfigData>
EOS2

done

# rules dir

ls $DIR_CONFIG | while read FILENAME; do 

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="$FILENAME auditd Config" Location="$FILENAME" Type="TXT">
EOS1

grep -E -v '^$|^\s*\#|^\s*;' $FILENAME | while read LINE; do
    entry_cdata "$LINE"
done 

cat <<-EOS2
    </ConfigData>
EOS2

done

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="auditctl auditd Config" Location="/usr/sbin/auditctl" Type="TXT">
EOS1

auditctl -l | while read LINE; do
    entry_cdata "$LINE"
done 

cat <<-EOS2
    </ConfigData>
EOS2

