
source incl/functions.sh

LOCATION=/etc/passwd

DATA=`grep -E -v '^(halt|sync|shutdown)' $LOCATION | awk -F: '($7 != "'"$(which nologin)"'" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
        if [ ! -d "$dir" ]; then
                echo "$user:The home directory ($dir) of user does not exist."
        else
                owner=$(stat -L -c "%U" "$dir")
                if [ "$owner" != "$user" ]; then
                        echo "$user:The home directory ($dir) of user is owned by $owner."
                fi
        fi
done`



# prevent '*' sign expansion
set -f

echo_log 'INFO' "Checking user home dirs ownership integrity"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Users home dir owership problems" Location="$LOCATION" Type="INI" ElementDelimiter=":">
EOS1

while IFS=: read K V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done  <<< $DATA


cat <<-EOS2
    </ConfigData>
EOS2

