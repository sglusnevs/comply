
source incl/functions.sh

echo_log 'INFO' 'Gathering mounts...'

LOCATION=/etc/fstab

# prevent occational asterisk in config be expanded to list of files
set -f

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Mounts" Location="$LOCATION" Type="INI">
EOS1

grep -v '^$\|^\s*\#' $LOCATION| while read -r LINE; do
    K=`echo "$LINE" | awk '{print $1}'`
    V=`echo "$LINE" | sed "s/^[^ ]* //"`
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
done

cat <<-EOS2
    </ConfigData>
EOS2


