
source incl/functions.sh

LOCATION=/etc/passwd

# prevent '*' sign expansion
set -f

echo_log 'INFO' "Gathering legacy '+' users from $LOCATION"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Legacy + users" Location="$LOCATION" Type="INI" ElementDelimiter="=">
EOS1

grep '^\+:' $LOCATION | while read L; do
    tag 6 `printf '<Entry Key="%s" Value=""/>' "$(quotemeta $L)"`
done 

cat <<-EOS2
    </ConfigData>
EOS2

