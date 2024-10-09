
source incl/functions.sh

# prevent '*' sign expansion
set -f

LOCATION=/etc/nsswitch.conf

echo_log 'INFO' "Gathering $LOCATION"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Nameservice Switch Config" Location="$LOCATION" Type="INI" ElementDelimiter=":">
EOS1

grep -v '^$\|^\s*\#' $LOCATION | while IFS=: read -r K V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done 

cat <<-EOS2
    </ConfigData>
EOS2
