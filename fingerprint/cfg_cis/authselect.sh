
source incl/functions.sh

echo_log 'INFO' 'Gathering authselect runtime configuration...'

# prevent '*' sign expansion
set -f

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="authselect runtime config" Location="/usr/bin/authselect current" Type="TXT">
EOS1

DATA=`authselect current`

while read -r LINE; do
    entry_cdata "$LINE"
done <<< "$DATA"

cat <<-EOS2
    </ConfigData>
EOS2

