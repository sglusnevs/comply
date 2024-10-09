
source incl/functions.sh

CFG_FILE="$CFG_PATH/sysctl.cfg"
DESC='Unconfined processes list'

# not all unixes have this config
test $CFG_FILE || exit 0

echo_log 'INFO' "Gathering $DESC..."

REFMOD=$(basename $BASH_SOURCE | sed -e 's/\.sh$//')

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="$DESC" Location="/usr/bin/ps -eo pid,user,label,cmd | grep unconfined_service_t" Type="INI" ElementDelimiter="=">
EOS1

/usr/bin/ps -eo pid,user,label,cmd | grep unconfined_service_t | while read LINE; do 

    VALUES=($LINE);
    PID=${VALUES[0]}
    USER=${VALUES[1]}
    CMD=${VALUES[@]:3}

    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $USER:$PID)" "$(quotemeta $CMD)"`
done

cat <<-EOS2
    </ConfigData>
EOS2
