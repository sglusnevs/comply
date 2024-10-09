
source incl/functions.sh

DESC='Ungrouped files'


echo_log 'INFO' "Gathering $DESC data..."

cat <<-EOS1
    <Files Label="$DESC">
EOS1

DATA=`df -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -nogroup | sort`


DIRNAME_LAST=''

while read -r FILE; do

    if [ ! -f "$FILE" ]; then
        continue
    fi

    DIRNAME=`dirname $FILE`
    FILENAME=`basename $FILE`

    if [ "$DIRNAME" != "$DIRNAME_LAST" ]; then

        if [ ! -z "$DIRNAME_LAST" ]; then
            tag 6 '</Dir>'
        fi

        DIR_META=($(ls -ld $DIRNAME))

        tag 6 `printf '<Dir Path="%s" Owner="%s" Group="%s">' "$DIRNAME" "${DIR_META[2]}" "${DIR_META[3]}"`
        tag 8 `printf '<Access Type="X" Rights="%s">.</Access>' "$(quotemeta ${DIR_META[0]})"`

        DIRNAME_LAST="$DIRNAME"
    fi

    FILE_META=($(ls -lk $FILE))
    tag 8 `printf '<File Name="%s" Size="%d" Owner="%s" Group="%s">' "$FILENAME" "${FILE_META[4]}" "${FILE_META[2]}" "${FILE_META[3]}"`
    tag 10 `printf '<Access Type="X" Rights="%s">.</Access>' "${FILE_META[0]}"` 
    tag 8 '</File>'
done <<< "$DATA"

if [ ! -z "$DIRNAME_LAST" ]; then
    tag 6 '</Dir>'
fi

cat <<-EOS2
    </Files>
EOS2
