
source incl/functions.sh

echo_log 'INFO' 'Gathering services info...'

# Check for Some Kernel Modules as well
CFG_FILE="$CFG_PATH/modprobe.cfg"

cat <<-EOS1
    <Services>
EOS1


export SYSTEMD_CONFIG_DIR=/lib/systemd/system
export IFS=' '

echo_log 'INFO' "Check for selected kernel modules from '$CFG_FILE' first..."

cat $CFG_FILE | while read -r LINE; do
    MODPROBE=`modprobe -n -v $LINE 2>/dev/null`
    LSMOD=`lsmod | grep $LINE`
    if [ ! -z "$LSMOD" ]; then
        STARTED=1
    else
        STARTED=0
    fi
    tag 9 '<Service Started="'$STARTED'">'
    section 11 'Name' $LINE.kernel
    section 11 'DisplayName' ${LINE//.kernel/}
    section 11 'Description' "$LINE kernel module"
    section 11 'StartName' 'root'
    section 11 'State' $MODPROBE
    tag 9 '</Service>'
done

systemctl list-units --type service --all --no-legend --no-pager | while read LINE; do
    TOKENS=($LINE)
    NAME=`quotemeta "${TOKENS[0]}"` 
    STATUS=`quotemeta "${TOKENS[2]}"` 
    echo_log 'DEBUG' "Parsed services line '$LINE' as '$NAME' => '$STATUS'"
    if [ "$STATUS" = "active" ]; then
        STARTED=1
    else
        STARTED=0
    fi
    USR=
    CMD=
    DESC=
    if [ -f "$SYSTEMD_CONFIG_DIR/$NAME" ]; then
        CMD=`grep -s ExecStart $SYSTEMD_CONFIG_DIR/$NAME |grep -v ExecStartPre | awk -F '[= ]' '{print $2}'`
        DESC=`grep -s Description= $SYSTEMD_CONFIG_DIR/$NAME | awk -F '=' '{print $2}'`
        PID=`systemctl status "$NAME" | grep 'Main PID' | awk -F'[: ]' '{print $5}'`
        USR=`ps -h -ouser -p $PID 2>/dev/null`
    fi
    tag 9 '<Service Started="'$STARTED'">'
    section 11 'Name' $NAME
    section 11 'DisplayName' ${NAME//.service/}
    section 11 'Description' "$DESC"
    section 11 'StartName' "$USR"
    section 11 'State' "$STATUS"
    tag 9 '</Service>'
done 



cat <<-EOS2
    </Services>
EOS2
