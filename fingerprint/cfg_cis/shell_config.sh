
source incl/functions.sh

echo_log 'INFO' 'Gathering shell settings...'

MAIN_CONFIG='/etc/bashrc /etc/profile /etc/profile.d/*.sh'

# main config 

ls $MAIN_CONFIG | while read FILENAME; do 

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="$FILENAME shell Config" Location="$FILENAME" Type="TXT">
EOS1

IFS=''
grep -E -v '^$|^\s*\#|^\s*;' $FILENAME | while read LINE; do
    echo "            <Line><![CDATA["$LINE"]]></Line>";
done 

cat <<-EOS2
    </ConfigData>
EOS2

done

