
source incl/functions.sh

LOCATION=/etc/passwd

DATA=`grep -E -v '^(halt|sync|shutdown)' $LOCATION | awk -F: '($7 != "'"$(which nologin)"'" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
        if [ ! -d "$dir" ]; then
                echo "$user:The home directory ($dir) of user does not exist."
        else
            if [ ! -h "$dir/.netrc" -a -f "$dir/.netrc" ]; then 
                echo "$user:.netrc file $dir/.netrc exists" 
            fi
        fi
done`



# prevent '*' sign expansion
set -f

echo_log 'INFO' "Checking if users' homes have .netrc files"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Users home .netrc files exist" Location="$LOCATION" Type="INI" ElementDelimiter=":">
EOS1

while IFS=: read K V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done  <<< $DATA


cat <<-EOS2
    </ConfigData>
EOS2

