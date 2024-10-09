
source incl/functions.sh

LOCATION=/etc/ftpusers

echo_log 'INFO' "Gathering $LOCATION"

# prevent '*' sign expansion
set -f


cat <<-EOS1
    <ConfigData Label="Users prohibited FTP access" Location="$LOCATION" Type="INI">
EOS1

grep -v '^$' $LOCATION | grep -v '^\s*#' | while read -r LINE; do
    V=$(chomp `quotemeta $LINE`)
    tag 6 `printf '<Entry Key="%s"/>' "$LINE"`
done 

cat <<-EOS2
    </ConfigData>
EOS2
