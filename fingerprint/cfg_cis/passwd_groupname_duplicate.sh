
source incl/functions.sh

REFMOD=$(basename $BASH_SOURCE | sed -e 's/\.sh$//')

LOCATION=/etc/group

# prevent '*' sign expansion
set -f

echo_log 'INFO' "Gathering duplicate group names information from $LOCATION"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Groups with duplicate names" Location="$LOCATION" Type="INI" ElementDelimiter="=">
EOS1

cut -d: -f1 $LOCATION | sort | uniq -d | while read x; do 
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $x)" "Duplicate group name (${x}) in $LOCATION"`
done

cat <<-EOS2
    </ConfigData>
EOS2

