
source incl/functions.sh

# prevent '*' sign expansion
set -f

LOCATION=/var/ldap/ldap_client_cred

echo_log 'INFO' "Gathering $LOCATION"

cat <<-EOS1
    <ConfigData Label="LDAP Client Credentials" Location="$LOCATION" Type="INI">
EOS1

grep -v '^$' $LOCATION | grep -v '^\s*#' | while IFS='=' read -r K V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done 

cat <<-EOS2
    </ConfigData>
EOS2
