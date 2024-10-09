
source incl/functions.sh

echo_log 'INFO' 'Gathering login policy settings...'

# prevent occational asterisk in config be expanded to list of files
set -f

cat <<-EOS1
    <SystemAccess>
EOS1

grep -v '^$' /etc/security/policy.conf | grep -v '^\s*#' | while IFS='=' read -r K V; do
    K=$(quotemeta $K)
    V=$(quotemeta $V)
    tag 6 `printf '<PolicySetting Name="%s" Value="%s" Precedence="1"/>' "$K" "$V"`
done 

cat <<-EOS2
    </SystemAccess>
EOS2
