
source incl/functions.sh

REFMOD=$(basename $BASH_SOURCE | sed -e 's/\.sh$//')

LOCATION=/etc/passwd
LOCATION2=/etc/group

# prevent '*' sign expansion
set -f

echo_log 'INFO' "Gathering infrmation about user homes from $LOCATION"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Check if user homes exist" Location="$LOCATION" Type="INI" ElementDelimiter="=">
EOS1


grep -E -v '^(halt|sync|shutdown)' $LOCATION | awk -F: '($7 != "'"$(which nologin)"'" && $7 != "/bin/false") { print $1 " " $6 }' | while read -r user dir; do 
    if [ ! -d "$dir" ]; then 
        tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $dir)" "The home directory ($dir) of user $user does not exist in $LOCATION"`
    fi 
done


cat <<-EOS2
    </ConfigData>
EOS2

