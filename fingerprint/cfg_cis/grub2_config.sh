
source incl/functions.sh

echo_log 'INFO' 'Gathering Grub2 settings...'

MAIN_CONFIG='/boot/grub2/user.cfg /boot/grub2/grubenv /etc/default/grub'

ls $MAIN_CONFIG | while read FILENAME; do 

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="$FILENAME Grub Config" Location="$FILENAME" Type="INI" ElementDelimiter="=">
EOS1

SECTION=

grep -E -v '^$|^\s*\#|^\s*;' $FILENAME | while IFS='=' read K V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done 

cat <<-EOS2
    </ConfigData>
EOS2

done
