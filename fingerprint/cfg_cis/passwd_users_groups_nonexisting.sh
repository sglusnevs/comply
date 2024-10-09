
source incl/functions.sh

LOCATION=/etc/passwd
LOCATION2=/etc/group

# prevent '*' sign expansion
set -f

echo_log 'INFO' "Gathering users from $LOCATION whose groups not exist in $LOCATION2"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Users with on existing groups assigned" Location="$LOCATION" Type="INI" ElementDelimiter="=">
EOS1


for i in $(cut -s -d: -f4 $LOCATION | sort -u ); do 
    grep -q -P "^.*?:[^:]*:$i:" $LOCATION2
    if [ $? -ne 0 ]; then 
        tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $i)" "$(quotemeta "Group $i is referenced by $LOCATION but does not exist in $LOCATION2")"`
    fi 
done

cat <<-EOS2
    </ConfigData>
EOS2

