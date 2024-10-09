
source incl/functions.sh

echo_log 'INFO' 'Gathering ipforwarding status...'

# prevent '*' sign expansion
set -f

cat <<-EOS1
    <ConfigData Label="Status of IP4 forwarding" Type="INI">
EOS1

routeadm -p ipv4-forwarding | while IFS='=' read -r SKIP SKIP SKIP CURRENT; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "ipv4-forwarding" "$(quotemeta $CURRENT)"`
done 

routeadm -p ipv6-forwarding | while IFS='=' read -r SKIP SKIP SKIP CURRENT; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "ipv6-forwarding" "$(quotemeta $CURRENT)"`
done

cat <<-EOS2
    </ConfigData>
EOS2

