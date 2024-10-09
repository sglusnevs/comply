
source incl/functions.sh

# prevent '*' sign expansion
set -f

echo_log 'INFO' "Gathering useradd default settings"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="useradd default settings" Location="useradd -D" Type="INI" ElementDelimiter="=">
EOS1

useradd -D | while IFS='=' read K V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done 

cat <<-EOS2
    </ConfigData>
EOS2

