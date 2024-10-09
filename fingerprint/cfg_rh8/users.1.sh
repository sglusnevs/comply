
source incl/functions.sh

echo_log 'INFO' 'Gathering local users...'

cat <<-EOS1
    <UserAccounts>
EOS1

# First, add netgroups
LOCATION=/etc/sssd/sssd.conf

LDAP_URI="unconfigured"
SEARCH_BASE="unknown"

if [ -f "$LOCATION" ]; then

    echo_log 'INFO' "Gathering Netgroups"

    DATA=`grep -E -v '^$|^\s*\#|^\s*;' $LOCATION`

    while IFS='=' read K V; do
        K=$(chomp "$K")
        V=$(quotemeta `chomp $V`)
        echo_log 'DEBUG' "'$K' => '$V'"
        case $K in
            'ldap_uri')
                LDAP_URI="$V"
                echo_log 'DEBUG' "$K found: '$V'"
                ;;
            'ldap_search_base')
                LDAP_SEARCH_BASE="$V"
                echo_log 'DEBUG' "$K found: '$V'"
                ;;
            'ldap_user_search_base')
                LDAP_USER_SEARCH_BASE="$V"
                echo_log 'DEBUG' "$K found: '$V'"
                ;;
        esac
    done  <<< "$DATA"

    if [ -z "$LDAP_USER_SEARCH_BASE" ]; then
        SEARCH_BASE="$LDAP_SEARCH_BASE"
    else 
        SEARCH_BASE="$LDAP_USER_SEARCH_BASE"
    fi
fi


while IFS=: read NAME LEG MUID GID GECOS MHOME MSHELL; do

        NAME=`quotemeta $NAME`
        GECOS=`quotemeta $GECOS`

        if [ -z "$NAME" ]; then
            continue
        fi

        # skip netgroups
        if [[ "$NAME" =~ ^\+@ ]]; then
            continue
        fi

        if [[ "$NAME" =~ ^\+ ]]; then
            echo_log 'DEBUG' "Parsing remote users line '$NAME' => '$LDAP_URI', '$SEARCH_BASE'"
            tag 8 `printf '<LocalUser Name="%s" SID="%s" Description="Netuser" Caption="%s"/>' "$NAME" "$LDAP_URI" "$SEARCH_BASE"`
        else 
            echo_log 'DEBUG' "Parsing local users line '$NAME' => '$MUID', '$GID', '$GECOS', '$MHOME', '$MSHELL'"
            tag 8 `printf '<LocalUser Name="%s" SID="%d" Description="%s" Caption=".\\\\%s"/>' "$NAME" "$MUID" "$GECOS" "$NAME"`
        fi

done  < /etc/passwd

cat <<-EOS2
    </UserAccounts>
EOS2
