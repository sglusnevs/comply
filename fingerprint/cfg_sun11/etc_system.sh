
source incl/functions.sh

LOCATION=/etc/system

echo_log 'INFO' 'Gathering $LOCATION...'

# prevent '*' sign expansion
set -f

cat <<-EOS1
    <ConfigData Label="System Settings" Location="$LOCATION" Type="INI">
EOS1

grep -v '^$' $LOCATION | grep -v '^\s*\*' | while IFS='=' read -r K V; do
    K=$(chomp `quotemeta $K`)
    V=$(chomp `quotemeta $V`)
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$K" "$V"`
done 

cat <<-EOS2
    </ConfigData>
EOS2
