
source incl/functions.sh

echo_log 'INFO' 'Gathering Software Update Statuses...'

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Security Update Status" Location="dnf check-update --security" Type="TXT">
EOS1

dnf check-update --security | grep -E -v '^$|^\s*\#|Last metadata' | awk '{print $1}' | while read LINE; do
    entry_cdata $LINE
done 

cat <<-EOS2
    </ConfigData>
EOS2

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Software Update Status" Location="dnf check-update" Type="TXT">
EOS1

dnf check-update | grep -E -v '^$|^\s*\#|Last metadata' | awk '{print $1}' | while read LINE; do
    entry_cdata $LINE
done 

cat <<-EOS2
    </ConfigData>
EOS2

