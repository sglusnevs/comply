
source incl/functions.sh

echo_log 'INFO' 'Gathering issue.net...'

# prevent '*' sign expansion
set -f

LOCATION=/etc/issue.net

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="issue.net" Location="$LOCATION" Type="TXT">
EOS1

grep -v '^$\|^\s*\#' $LOCATION | while read -r LINE; do
    entry_cdata "$LINE"
done 

cat <<-EOS2
    </ConfigData>
EOS2
