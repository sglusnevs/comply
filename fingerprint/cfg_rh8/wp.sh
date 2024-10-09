
source incl/functions.sh

CFG_FILE="$CFG_PATH/wp.cfg"
DESC='Write Protection'

echo_log 'INFO' "Gathering files metadata '$DESC' from '$CFG_FILE'..."

cat <<-EOS1
    <Files Label="$DESC">
EOS1

cat $CFG_FILE | while read -r DIR; do
    echo_log 'INFO' "Gathering metadata for $DIR"
    if [ ! -f "$DIR" -a ! -d "$DIR" ]; then
        echo_log 'ERROR' "$DIR not found"
        continue
    fi
    # test -L "$DIR" && DIR=$(dirname $DIR)`readlink $DIR`
    # first, output directories, including entry itself
    DIR_META=(`ls -ld $DIR`) 
    tag 6 `printf '<Dir Path="%s" Owner="%s" Group="%s">' "$(quotemeta $DIR)" "$(quotemeta ${DIR_META[2]})" "$(quotemeta ${DIR_META[3]})"`
    tag 10 `printf '<Access Type="X" Rights="%s">.</Access>' "$(quotemeta ${DIR_META[0]})"`
    for TYPE in d f; do
        IDX=0
        echo_log 'DEBUG' "Getting data of type "$TYPE" in '$DIR'"
        find "$DIR" -type $TYPE  -printf '%i %k %M %n %u %g %s %T+%Tz %p\n' | sed -e 's/+/T/' | while read INODE SIZE_KB RIGHTS HLINKS OWNER GROUP SIZE_BYTES MTIME FILENAME; do
            # skip dir self
            if [ "$IDX" = '0' -a "$FILENAME" = "$DIR" ]; then
                continue
            fi
            BASENAME=`basename "$FILENAME"`
            echo_log 'DEBUG' "Checking $FILENAME"
            if [[ "$TYPE" = 'd' ]]; then
                tag 10 `printf '<SubDir Path="%s" Owner="%s" Group="%s">' "$(quotemeta $BASENAME)" "$(quotemeta $OWNER)" "$(quotemeta $GROUP)"`
                tag 14 `printf '<Access Type="X" Rights="%s">.</Access>' "$(quotemeta $RIGHTS)"`
                tag 10 '</SubDir>'
            elif [[ "$TYPE" = 'f' ]]; then
                tag 10 `printf '<File Name="%s" Size="%d" Owner="%s" Group="%s" Modified="%s">' "$(quotemeta $BASENAME)" "$(quotemeta $SIZE_KB)" "$(quotemeta $OWNER)" "$(quotemeta $GROUP)" "$(quotemeta $MTIME)"`
                tag 14 `printf '<Access Type="X" Rights="%s">.</Access>' "$(quotemeta $RIGHTS)"`
                tag 10 '</File>'
            fi
            IDX=$((IDX+1))
        done 
    done
    tag 6 '</Dir>'
done

cat <<-EOS2
    </Files>
EOS2
