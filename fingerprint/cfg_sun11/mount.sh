
source incl/functions.sh

echo_log 'INFO' 'Gathering mounts...'

LOCATION=/etc/vfstab

# prevent occational asterisk in config be expanded to list of files
set -f

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Mounts" Location="$LOCATION" Type="INI">
EOS1

grep -v '^\s*#' $LOCATION| while read -r LINE; do
    if [ ! -z "$LINE" ]; then
        K=`echo "$LINE" | awk '{print $1}'`
        V=`echo "$LINE" | /usr/xpg4/bin/sed "s/^[^ ]* //"`
    	tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
    fi
done

cat <<-EOS2
    </ConfigData>
EOS2


