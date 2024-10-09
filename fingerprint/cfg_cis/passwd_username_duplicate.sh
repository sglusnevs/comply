
source incl/functions.sh

REFMOD=$(basename $BASH_SOURCE | sed -e 's/\.sh$//')

LOCATION=/etc/passwd

# prevent '*' sign expansion
set -f

echo_log 'INFO' "Gathering duplicate user names information from $LOCATION"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Users with duplicate names" Location="$LOCATION" Type="INI" ElementDelimiter="=">
EOS1

cut -d: -f1 /etc/passwd | sort | uniq -d | while read x; do 
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $x)" "Duplicate login name (${x}) in /etc/passwd"`
done

cat <<-EOS2
    </ConfigData>
EOS2

