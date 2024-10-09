source incl/functions.sh

LOCATION=/etc/default/inetinit

echo_log 'INFO' "Gathering $LOCATION Settings"

# prevent '*' sign expansion
set -f


cat <<-EOS1
    <ConfigData Label="/etc/default/inetinit settings" Location="$LOCATION" Type="INI">
EOS1

grep -v '^$' $LOCATION | grep -v '^\s*#' | while IFS='=' read -r K V; do
    # get first word of config file as key
    K=$(chomp `quotemeta $K`)
    V=$(chomp `quotemeta $V`)
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$K" "$V"`
done

cat <<-EOS2
    </ConfigData>
EOS2

