
source incl/functions.sh

echo_log 'INFO' 'Gathering /etc/sysconfig data...'

CFG_FILE="$CFG_PATH/sysconfig_config.cfg"
BASEDIR='/etc/sysconfig'

cat $CFG_FILE | while read SERVICE; do 

FILENAME="$BASEDIR/$SERVICE"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="$SERVICE Sysconfig" Location="$FILENAME" Type="INI" ElementDelimiter="=">
EOS1

DATA=`grep -E -v '^$|^\s*\#|^\s*;' $FILENAME`
while IFS='=' read K V; do
    if [ "$K" != "" ]; then
        tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
    fi
done <<< "$DATA"

cat <<-EOS2
    </ConfigData>
EOS2

done
