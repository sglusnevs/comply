
source incl/functions.sh

echo_log 'INFO' 'Gathering ipadm settings...'

# prevent '*' sign expansion
set -f

cat <<-EOS1
    <ConfigData Label="Status of ipadm values" Type="INI">
EOS1

svccfg -s system-log listprop config/log_from_remote |  while read -r K T V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done 

svccfg -s svc:/system/keymap:default listprop|grep -i keyboard_abort |  while read -r K T V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done 

cat <<-EOS2
    </ConfigData>
EOS2

