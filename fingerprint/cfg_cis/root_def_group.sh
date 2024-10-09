
source incl/functions.sh

echo_log 'INFO' 'Gathering root default group...'

# main config 

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Root user default group" Location="/etc/passwd" Type="TXT">
EOS1

grep "^root:" /etc/passwd | cut -f4 -d: | while read LINE; do
    entry_cdata "$LINE"
done 

cat <<-EOS2
    </ConfigData>
EOS2

