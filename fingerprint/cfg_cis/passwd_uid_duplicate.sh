
source incl/functions.sh

REFMOD=$(basename $BASH_SOURCE | sed -e 's/\.sh$//')

LOCATION=/etc/passwd

# prevent '*' sign expansion
set -f

echo_log 'INFO' "Gathering duplicate UIDs information from $LOCATION"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Users with duplicate UIDs" Location="$LOCATION" Type="INI" ElementDelimiter="=">
EOS1


cut -f3 -d":" $LOCATION | sort -n | uniq -c | while read x ; do 
    [ -z "$x" ] && break 
    set - $x 
    if [ $1 -gt 1 ]; then 
        users=$(awk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd | xargs) 
        tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $2)" "$(quotemeta $users)"`
    fi 
done

cat <<-EOS2
    </ConfigData>
EOS2

