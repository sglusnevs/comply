
source incl/functions.sh

REFMOD=$(basename $BASH_SOURCE | sed -e 's/\.sh$//')

LOCATION=/etc/passwd
LOCATION2=/etc/group

# prevent '*' sign expansion
set -f

echo_log 'INFO' "Gathering users belonging to shadow group data information from $LOCATION"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Shadow group users" Location="$LOCATION" Type="INI" ElementDelimiter="=">
EOS1

export SHADOW_GUID=`egrep ^shadow:[^:]*:[^:]*:[^:]+ $LOCATION2 | cut -d: -f 3`

awk -v SHADOW_GUID="$SHADOW_GUID" -F: '($4 == SHADOW_GUID) { print }' $LOCATION | while read x; do
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $x)" "User belong to shadow group (${x}) in $LOCATION"`
done

cat <<-EOS2
    </ConfigData>
EOS2

