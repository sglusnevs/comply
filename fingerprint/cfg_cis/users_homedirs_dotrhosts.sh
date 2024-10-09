
source incl/functions.sh

LOCATION=/etc/passwd

DATA=`grep -E -v '^(halt|sync|shutdown)' $LOCATION | awk -F: '($7 != "'"$(which nologin)"'" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
        if [ ! -d "$dir" ]; then
                echo "$user:The home directory ($dir) of user does not exist."
        else
            for file in $dir/.rhosts; do 
                if [ ! -h "$file" -a -f "$file" ]; then 
                    echo "$user:.rhosts file in $dir" 
                fi 
            done
        fi
done`



# prevent '*' sign expansion
set -f

echo_log 'INFO' "Checking if users' homes have .rhosts files"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Users home .rhosts files exist" Location="$LOCATION" Type="INI" ElementDelimiter=":">
EOS1

while IFS=: read K V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done  <<< $DATA


cat <<-EOS2
    </ConfigData>
EOS2

