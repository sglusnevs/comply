
source incl/functions.sh

echo_log 'INFO' 'Gathering SELinux settings...'

MAIN_CONFIG='/etc/selinux/config'

ls $MAIN_CONFIG | while read FILENAME; do 

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="SELinux Config" Location="$FILENAME" Type="INI" ElementDelimiter="=">
EOS1

SECTION=

grep -E -v '^$|^\s*\#|^\s*;' $FILENAME | while IFS='=' read K V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done 

cat <<-EOS2
    </ConfigData>
EOS2

done
