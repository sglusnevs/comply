
source incl/functions.sh

echo_log 'INFO' 'Gathering NTP Client Settings...'

# prevent '*' sign expansion
set -f

LOCATION=/etc/ntp.conf

cat <<-EOS1
    <ConfigData Label="NTP Client Config" Location="$LOCATION" Type="INI">
EOS1

grep -v '^$' $LOCATION | grep -v '^\s*#' | while read -r K V; do
    K=$(chomp `quotemeta $K`)
    V=$(chomp `quotemeta $V`)
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$K" "$V"`
done 

cat <<-EOS2
    </ConfigData>
EOS2
