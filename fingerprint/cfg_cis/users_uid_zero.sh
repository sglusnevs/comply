
source incl/functions.sh

LOCATION=/etc/passwd

# prevent '*' sign expansion
set -f

echo_log 'INFO' "Gathering users with UID 0 from $LOCATION"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Users with UID 0" Location="$LOCATION" Type="INI" ElementDelimiter="=">
EOS1

awk -F: '($3 == 0) { print $1 " " $3 }' $LOCATION | while read K V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done 

cat <<-EOS2
    </ConfigData>
EOS2

