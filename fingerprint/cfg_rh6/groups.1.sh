
source incl/functions.sh

cat <<-EOS1
    <GroupAccounts>
EOS1

# First, add netgroups
LOCATION_SSSD=/etc/sssd/sssd.conf
LOCATION_ACCESS_CONF=/etc/security/access.conf

echo_log 'INFO' "Gathering Netgroups data from $LOCATION_SSSD"

LDAP_URI="unconfigured"
SEARCH_BASE="unknown"

if [ -f "$LOCATION_SSSD" ]; then

    DATA=`grep -E -v '^$|^\s*\#|^\s*;' $LOCATION_SSSD`

    while IFS='=' read K V; do
        K=$(chomp $K)
        V=$(quotemeta `chomp $V`)
        echo_log 'DEBUG' "'$K' => '$V'"
        case $K in
            'ldap_uri')
                LDAP_URI="$V"
                echo_log 'DEBUG' "LDAP_URI found: $LDAP_URI"
                echo_log 'DEBUG' "$K found: '$V'"
                ;;
            'ldap_search_base')
                LDAP_SEARCH_BASE="$V"
                echo_log 'DEBUG' "LDAP_SEARCH_BASE found: $LDAP_SEARCH_BASE"
                echo_log 'DEBUG' "$K found: '$V'"
                ;;
            'ldap_group_search_base')
                LDAP_GROUP_SEARCH_BASE="$V"
                echo_log 'DEBUG' "LDAP_GROUP_SEARCH_BASE found: $LDAP_GROUP_SEARCH_BASE"
                echo_log 'DEBUG' "$K found: '$V'"
                ;;
        esac
    done  <<< "$DATA"

    if [ -z "$LDAP_GROUP_SEARCH_BASE" ]; then
        SEARCH_BASE="$LDAP_SEARCH_BASE"
    else 
        SEARCH_BASE="$LDAP_GROUP_SEARCH_BASE"
    fi

    echo_log 'DEBUG' "LDAP: '$LDAP_URI' '$SEARCH_BASE'"

    echo_log 'INFO' 'Gathering netgroups info...'


    # Note: information about netgroups is stored in /etc/passwd, not /etc/group!
    while IFS=: read NAME LEG MUID GID GECOS MHOME MSHELL; do

            NAME=`quotemeta $(chomp "$NAME")`
            GECOS=`quotemeta $(chomp "$GECOS")`

            echo_log 'DEBUG' " '$NAME' => '$MUID', '$GID', '$GECOS', '$MHOME', '$MSHELL'"

            # show only remote groups this time
            if [[ ! "$NAME" =~ ^\+@ ]]; then
                continue
            fi

            NAME=`echo $NAME |sed -e 's/^\+@//'`

            CAPTION="$SEARCH_BASE"

            tag 8 `printf '<LocalGroup Name="@%s" SID="%s" Description="Netgroup" Caption="LDAP\%s"/>' "$NAME" "$NAME" "$NAME"`
    done  < /etc/passwd
fi

echo_log 'INFO' "Gathering Netgroups data from $LOCATION_ACCESS_CONF"

if [ -f "$LOCATION_ACCESS_CONF" ]; then

    DATA=`grep -E -v '^$|^\s*\#|^\s*;' $LOCATION_ACCESS_CONF | grep @`

    while IFS=':' read K V M; do
        K=$(chomp $K)
        NAME=$(quotemeta `chomp $V`)
        echo_log 'DEBUG' "'$K' => '$V'"
        case $K in
            '+')
                echo_log 'DEBUG' "+ netgroup found in $LOCATION_ACCESS_CONF: $NAME"
                tag 8 `printf '<LocalGroup Name="%s" SID="%s" Description="Netgroup" Caption="LDAP\%s"/>' "$NAME" "$NAME" "$NAME"`
                ;;
        esac
    done  <<< "$DATA"
fi

echo_log 'INFO' 'Gathering local groups info...'

while IFS=':' read NAME LEG MUID MEMBERS; do
        MUID=`quotemeta $MUID`
        NAME=`quotemeta $NAME`
        echo_log 'DEBUG' "Found local group '$NAME' ID '$MUID'"
        echo_log 'DEBUG' "List of '$NAME' members who has it as secondary: '$MEMLIST'"

        # check who has this group as primary
        while IFS=: read UNAME ULEG UMUID UGID_PRIMARY UGECOS UMHOME UMSHELL; do
            if [[ "$UGID_PRIMARY" =  "$MUID" ]]; then
                echo_log 'DEBUG' "User '$UNAME' has group '$NAME' as primary"

                if [ -z "$MEMBERS" ]; then
                    MEMBERS="$UNAME"
                else
                    MEMBERS="$MEMBERS,$UNAME"
                fi
            fi
        done < /etc/passwd

        IFS=, MEMLIST=($MEMBERS)
        echo_log 'DEBUG' "Full list of '$NAME' members: '$MEMLIST'"

        # note: we added here so many backslashes to prevent evaluating users starting with 't' (like 'tty')
        # first letter be evaluated as 'backslash-t', i.e. 'TAB' (ASCII 9) character later when printing this data out
        if [ -z "$MEMLIST" ]; then
            tag 8 `printf '<LocalGroup Name="%s" SID="%d" Caption=".\\\\%s"/>' "$NAME" "$MUID" "$NAME"`
        else
            tag 8 `printf '<LocalGroup Name="%s" SID="%d" Caption=".\\\\%s">' "$NAME" "$MUID" "$NAME"`
            tag 10 '<Members>'
            for MEM in ${MEMLIST[*]}; do 
                tag 12 `printf '<Member Domain="." ID="%s" Type="UserAccount"/>' "$MEM"`
            done
            tag 10 '</Members>'
            tag 8 '</LocalGroup>'
        fi
done  < /etc/group

cat <<-EOS2
    </GroupAccounts>
EOS2
