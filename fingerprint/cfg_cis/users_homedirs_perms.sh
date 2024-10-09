
source incl/functions.sh

LOCATION=/etc/passwd

DATA=`grep -E -v '^(halt|sync|shutdown)' $LOCATION | awk -F: '($7 != "'"$(which nologin)"'" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
        if [ ! -d "$dir" ]; then
                echo "$user:The home directory ($dir) of user does not exist"
        else
                dirperm=$(ls -ld $dir | cut -f1 -d" ")
                if [ $(echo $dirperm | cut -c6) != "-" ]; then
                        echo "$user:Group Write permission set on the home directory ($dir) of user"
                fi
                if [ $(echo $dirperm | cut -c8) != "-" ]; then
                        echo "$user:Other Read permission set on the home directory ($dir) of user"
                fi
                if [ $(echo $dirperm | cut -c9) != "-" ]; then
                        echo "$user:Other Write permission set on the home directory ($dir) of user"
                fi
                if [ $(echo $dirperm | cut -c10) != "-" ]; then
                        echo "$user:Other Execute permission set on the home directory ($dir) of user"
                fi
        fi
done`


# prevent '*' sign expansion
set -f

echo_log 'INFO' "Checking user home dirs permission integrity"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Users home dir permissions problems" Location="$LOCATION" Type="INI" ElementDelimiter=":">
EOS1

while IFS=: read K V; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done  <<< $DATA

cat <<-EOS2
    </ConfigData>
EOS2

