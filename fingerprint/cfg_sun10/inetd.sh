
source incl/functions.sh

LOCATION=/etc/inet/inetd.conf

echo_log 'INFO' 'Gathering $LOCATION...'

# prevent '*' sign expansion
set -f

cat <<-EOS1
    <ConfigData Label="Services Configured in $LOCATION" Location="$LOCATION" Type="INI">
EOS1

grep -v '^$' $LOCATION | grep -v '^\s*#' | while read -r LINE; do
    LINE_D=($LINE)
    K=$(chomp `quotemeta ${LINE_D[0]}`)
    V=$(chomp `quotemeta ${LINE_D[5]}`)
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$K" "$V"`
done 

cat <<-EOS2
    </ConfigData>
EOS2
