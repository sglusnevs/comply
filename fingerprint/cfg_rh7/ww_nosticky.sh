
source incl/functions.sh

DESC='World-writable directories without stisky bit set'

echo_log 'INFO' "Gathering files metadata '$DESC'..."

cat <<-EOS1
    <Files Label="$DESC">
EOS1

df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null | while read -r DIR; do
    # first, output directories, including entry itself
    DIR_META=(`ls -ld $DIR`) 
    tag 6 `printf '<Dir Path="%s" Owner="%s" Group="%s">' "$(quotemeta $DIR)" "$(quotemeta ${DIR_META[2]})" "$(quotemeta ${DIR_META[3]})"`
    tag 10 `printf '<Access Type="X" Rights="%s">.</Access>' "$(quotemeta ${DIR_META[0]})"`
    tag 6 '</Dir>'
done

cat <<-EOS2
    </Files>
EOS2
