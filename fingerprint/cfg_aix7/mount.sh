
source incl/functions.sh

LOCATION=/etc/filesystems

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Mounts" Location="$LOCATION" Type="WININI" ElementDelimiter="=">
EOS1

SECTION=


DATA=`grep -E -v '^$|^\s*\#|^\s*;' $LOCATION`
while IFS='=' read K V; do
    if [[ $K =~ :$ ]]; then
        if [ ! -z "$SECTION" ]; then
            # section closed without any key found
            tag 6 `printf '</Section>'`
            SECTION=
        fi
        SECTION=$(echo "$K" | sed 's/:$//g' ) # replace trailing :
        tag 6 `printf '<Section Name="%s">' "$(quotemeta $SECTION)"`
    elif [ ! -z "$SECTION" ]; then
        tag 8 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
    fi
done <<< "$DATA"

if [ ! -z "$SECTION" ]; then
    # close remaining section 
    tag 6 `printf '</Section>'`
fi

cat <<-EOS2
    </ConfigData>
EOS2
