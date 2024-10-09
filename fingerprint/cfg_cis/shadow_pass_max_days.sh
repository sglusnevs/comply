
source incl/functions.sh

LOCATION=/etc/shadow

# prevent '*' sign expansion
set -f

echo_log 'INFO' "Gathering max password age from $LOCATION"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="User max password age" Location="$LOCATION" Type="INI" ElementDelimiter=":">
EOS1

grep -E '^[^:]+:[^!*]' /etc/shadow | cut -d: -f1,5 | while IFS=':' read K V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done 

cat <<-EOS2
    </ConfigData>
EOS2

