
source incl/functions.sh

echo_log 'INFO' 'Gathering ipforwarding Settings...'

# prevent '*' sign expansion
set -f

cat <<-EOS1
    <ConfigData Label="IP Forwarding Config" Type="INI">
EOS1

no -o ipforwarding | while IFS='=' read -r K V; do
    K=$(chomp `quotemeta $K`)
    V=$(chomp `quotemeta $V`)
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$K" "$V"`
done 

cat <<-EOS2
    </ConfigData>
EOS2
