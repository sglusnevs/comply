
source incl/functions.sh

REFMOD=$(basename $BASH_SOURCE | sed -e 's/\.sh$//')

LOCATION=/etc/group

# prevent '*' sign expansion
set -f

echo_log 'INFO' "Gathering duplicate GIDs information from $LOCATION"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Groups with duplicate GIDs" Location="$LOCATION" Type="INI" ElementDelimiter="=">
EOS1


cut -d: -f3 $LOCATION | sort | uniq -d | while read x ; do 
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $x)" "Duplicate GID ($x) in /etc/group"`
done

cat <<-EOS2
    </ConfigData>
EOS2

