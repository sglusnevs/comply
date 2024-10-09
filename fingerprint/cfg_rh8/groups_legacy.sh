
source incl/functions.sh

LOCATION=/etc/group

# prevent '*' sign expansion
set -f

echo_log 'INFO' "Gathering legacy '+' groups from $LOCATION"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Legacy + groups" Location="$LOCATION" Type="INI" ElementDelimiter="=">
EOS1

grep -v '^\+:' $LOCATION | while read L; do
    tag 6 `printf '<Entry Key="%s" Value=""/>' "$(quotemeta $L)"`
done 

cat <<-EOS2
    </ConfigData>
EOS2

