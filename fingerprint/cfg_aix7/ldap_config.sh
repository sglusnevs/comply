
source incl/functions.sh

LOCATION=/etc/security/ldap/ldap.cfg

echo_log 'INFO' 'Gathering $LOCATION...'

# prevent occational asterisk in config be expanded to list of files
set -f

cat <<-EOS1
    <ConfigData Label="LDAP Client Config" Location="$LOCATION" Type="WININI">
EOS1

PREFIX=
grep -v '^\#' $LOCATION | grep -v '^$' | while IFS=':' read -r K V; do
    K=$(chomp $K)
    V=$(chomp $V)
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`

done

cat <<-EOS2
    </ConfigData>
EOS2
