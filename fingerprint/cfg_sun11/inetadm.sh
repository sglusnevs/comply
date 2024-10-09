
source incl/functions.sh

echo_log 'INFO' 'Gathering inetd Services...'

# prevent '*' sign expansion
set -f

cat <<-EOS1
    <ConfigData Label="inetd Allowed Services" Location="$LOCATION" Type="INI">
EOS1

inetadm | grep -v '^ENABLED' | while read -r ENABLED STATE FMRI; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $FMRI)" "$(quotemeta $ENABLED/$STATE)"`
done 

cat <<-EOS2
    </ConfigData>
EOS2
