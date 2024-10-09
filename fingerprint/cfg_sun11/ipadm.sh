
source incl/functions.sh

echo_log 'INFO' 'Gathering ipadm settings...'

# prevent '*' sign expansion
set -f

cat <<-EOS1
    <ConfigData Label="Status of ipadm values" Type="INI">
EOS1

ipadm show-prop -p forwarding  ipv6 | tail -1 |  while read -r LINE; do
    LINE_D=($LINE)
    tag 6 `printf '<Entry Key="ipadm-forwarding-ipv6" Value="%s"/>' "$(quotemeta ${LINE_D[3]})"`
done 

ipadm show-prop -p smallest_anon_port tcp | tail -1 |  while read -r LINE; do
    LINE_D=($LINE)
    tag 6 `printf '<Entry Key="ipadm-smallest_anon_port-tcp" Value="%s"/>' "$(quotemeta ${LINE_D[3]})"`
done 

ipadm show-prop -p smallest_nonpriv_port tcp | tail -1 |  while read -r LINE; do
    LINE_D=($LINE)
    tag 6 `printf '<Entry Key="ipadm-smallest_nonpriv_port-tcp" Value="%s"/>' "$(quotemeta ${LINE_D[3]})"`
done 

cat <<-EOS2
    </ConfigData>
EOS2

