
source incl/functions.sh

CFG_FILE="$CFG_PATH/kernel_net.cfg"
DESC='Kernel IPv4 Parameters'

# not all unixes have this config
test $CFG_FILE || exit 0

echo_log 'INFO' "Gathering files metadata '$DESC' from '$CFG_FILE'..."

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="$DESC" Location="/proc/sys/net" Type="INI" ElementDelimiter="=">
EOS1

cat $CFG_FILE | while read -r LINE; do
    V=`cat $LINE`
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $LINE)" "$(quotemeta $V)"`
done

cat <<-EOS2
    </ConfigData>
EOS2
