
source incl/functions.sh

echo_log 'INFO' 'Gathering login policy settings...'

cat <<-EOS1
    <SystemAccess>
EOS1

grep -v '^$\|^\s*\#' /etc/login.defs | while read -r K V; do
    K=$(quotemeta $K)
    V=$(quotemeta $V)
    tag 6 `printf '<PolicySetting Name="%s" Value="%s" Precedence="1"/>' "$K" "$V"`
done 

cat <<-EOS2
    </SystemAccess>
EOS2
