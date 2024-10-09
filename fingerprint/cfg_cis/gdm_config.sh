
source incl/functions.sh

echo_log 'INFO' 'Gathering GDM3 configs...'

CFG_FILE="$CFG_PATH/gdm_config.cfg"

cat $CFG_FILE | while read FILE; do 

FILENAME="$FILE"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="GDM $FILE Config" Location="$FILENAME" Type="WININI">
EOS1

SECTION=

DATA=`grep -E -v '^$|^\s*\#|^\s*;' $FILENAME`
while IFS='=' read K V; do
    if [[ $K == \[* ]]; then
        if [ ! -z "$SECTION" ]; then
            # section closed without any key found
            tag 6 `printf '</Section>'`
            SECTION=
        fi
        SECTION=$K
        tag 6 `printf '<Section Name="%s">' "$(quotemeta $SECTION)"`
    else
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

done
