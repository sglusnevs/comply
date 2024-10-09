
source incl/functions.sh

echo_log 'INFO' 'Gathering services info...'

cat <<-EOS1
    <Services>
EOS1


export IFS=' '
ps -eo  "%u %a" | grep -v 'RUSER COMMAND' | while read LINE; do
    TOKENS=($LINE);
    USER=`quotemeta "${TOKENS[0]}"` 
    CMD=`quotemeta "${TOKENS[@]:1}"` 
    echo_log 'DEBUG' "Parsed services line '$LINE' as '$USER' => '$CMD'"
    tag 9 '<Service Started="1">'
    section 11 'Name' $CMD
    section 11 'DisplayName' $CMD
    section 11 'StartName' $USER
    tag 9 '</Service>'
done 

cat <<-EOS2
    </Services>
EOS2
