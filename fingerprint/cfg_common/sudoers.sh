
source incl/functions.sh

echo_log 'INFO' 'Gathering SUDO settings...'

ls /etc/sudoers /etc/sudoers.d/* | while read LOCATION; do

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Sudoers Data" Location="$LOCATION" Type="TXT">
EOS1

grep -v '^$' /etc/sudoers | grep -v '^#' | while read -r LINE; do
    entry_cdata "$LINE"
done 

cat <<-EOS2
    </ConfigData>
EOS2

done
