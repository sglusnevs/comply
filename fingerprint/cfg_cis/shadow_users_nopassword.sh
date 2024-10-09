
source incl/functions.sh

LOCATION=/etc/shadow

# prevent '*' sign expansion
set -f

echo_log 'INFO' "Gathering users without password from $LOCATION"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Users with empty password field" Location="$LOCATION" Type="INI" ElementDelimiter="=">
EOS1

awk -F: '($2 == "" ) { print $1 }' $LOCATION | while read L; do
    tag 6 `printf '<Entry Key="%s" Value=""/>' "$(quotemeta $L)"`
done 

cat <<-EOS2
    </ConfigData>
EOS2

