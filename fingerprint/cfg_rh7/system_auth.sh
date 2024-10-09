
source incl/functions.sh

# prevent '*' sign expansion
set -f

LOCATION=/etc/pam.d/system-auth

echo_log 'INFO' "Gathering $LOCATION"

cat <<-EOS1
    <ConfigData Label="System Auth Config" Location="$LOCATION" Type="TXT">
EOS1

grep -E -v '^$|^\s*\#' $LOCATION | sed -re 's/\s{1,}/ /g' | grep -E -v '^$|^\s*\#' | while read LINE; do
    entry_cdata "$LINE"
done 

cat <<-EOS2
    </ConfigData>
EOS2
