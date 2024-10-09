
source incl/functions.sh

# prevent '*' sign expansion
set -f

CFG_FILE_TXT='/etc/pam.d/system-auth /etc/pam.d/password-auth /etc/pam.d/su'
CFG_FILE_INI='/etc/security/pwquality.conf'

for LOCATION in $CFG_FILE_TXT ; do

echo_log 'INFO' "Gathering $LOCATION"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="System Auth Config" Location="$LOCATION" Type="TXT">
EOS1

grep -E -v '^$|^\s*\#' $LOCATION | sed -re 's/\s{1,}/ /g' | grep -E -v '^$|^\s*\#' | while read LINE; do
    entry_cdata "$LINE"
done 

cat <<-EOS2
    </ConfigData>
EOS2

done

for LOCATION in $CFG_FILE_INI; do

echo_log 'INFO' "Gathering $LOCATION"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="System Auth Config" Location="$LOCATION" Type="INI">
EOS1

grep -E -v '^$|^\s*\#' $LOCATION | grep -E -v '^$|^\s*\#' | while IFS='=' read K V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done 

cat <<-EOS2
    </ConfigData>
EOS2

done
