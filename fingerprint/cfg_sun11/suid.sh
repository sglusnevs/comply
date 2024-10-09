
source incl/functions.sh

DESC='SUID and SGID files'


echo_log 'INFO' "Gathering files metadata for SUID and SGID files..."

cat <<-EOS1
    <Files Label="$DESC">
EOS1

DATA=`/usr/xpg4/bin/df -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' \( -perm -4000 -o -perm -2000 \) -type f| sort`

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

    FILE_META=($(ls -l $FILE))
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
