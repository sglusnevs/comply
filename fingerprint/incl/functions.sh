
# extract current module name to add to the resulting XML
MODNAME=`basename $(caller | cut -d' ' -f 2) | cut -d. -f 1`


# Function to translate semantic loglevel into numerical representation
function loglevel_num() {
    LEVEL=$1
    case $LEVEL in
        DEBUG)
            # Very detailed info about each command executed and its output 
            LEVEL=1
        ;;
        INFO)
            # Inormative messages; this should be default
            LEVEL=2
        ;;
        WARN)
            # Only important warnings
            LEVEL=3
        ;;
        FATAL|*)
            # Only if something fails; this also means skript exits
            LEVEL=4
        ;;
    esac
    echo $LEVEL
}

# Function to print to STDERR
function echo_stderr(){ 
    >&2 echo "$@" 
}

function echo_stderr_nonl(){ 
    >&2 echo -n "$@" 
}

# Function to protocol script execution accordingly to loglevel set
function echo_log() {
    MINLEVEL=$1
    MINLEVEL_NUM=`loglevel_num $MINLEVEL`
    MINLEVEL_CUR=`loglevel_num $LOGLEVEL`
    MSG="${@:2}"
    if [ $MINLEVEL_NUM -lt $MINLEVEL_CUR ]; then
        return
    fi

    echo_stderr `date` " - $MINLEVEL - $MSG"

    if [ 'FATAL' = "$MINLEVEL" ]; then
        exit 1
    fi
}

# Executes command and protocols its execution if loglevel it set for it
function exec_cmd() {
    echo_log 'DEBUG' "EXEC_CMD LINE `caller`" \"$@\"
    RET=`$@`
    RC=$?
    echo_log 'DEBUG' "EXEC_CMD RC $RC:" \"$RET\"
    if [ "$RC" -ne "0" ]; then
        echo_log 'FATAL' "EXEC_CMD LINE `caller`" \"$@\"
    fi
    echo $RET
    return $RC
}

# Executes one of modules from cfg_* folder
function exec_module() {
    MODULE_MODULE="$1"
    MODULE_FILE_COMMON="$CFG_COMMON/$MODULE_MODULE.sh"
    MODULE_FILE_CFG="$CFG_PATH/$MODULE_MODULE.sh"

    echo_log 'DEBUG' "MODULE '$MODULE_MODULE', common config '$MODULE_FILE_COMMON', specific '$MODULE_FILE_CFG'"

    # first, try to load common module
    if [ -x "$MODULE_FILE_COMMON" ]; then
        echo_log 'INFO' "MODULE '$MODULE_MODULE' common for all flavors found, running"
        MODULE_CMD=$MODULE_FILE_COMMON
    elif [ -x "$MODULE_FILE_CFG" ]; then
        # if does not exist, try specific
        echo_log 'INFO' "MODULE '$MODULE_MODULE' specific for '$FVERSION' found, running"
        MODULE_CMD=$MODULE_FILE_CFG
    else
        # otherwise do not run it
        echo_log 'INFO' "MODULE '$MODULE_FILE' does not exist for this OS, skipping"
        return 0
    fi

    # run module
    echo_log 'DEBUG' "MODULE '$MODULE_CMD'"
    if [ -n "$MODTRACE" ]; then
        # incldue module, filter output to set time to XML format
        source $MODULE_CMD | sed -e 's/\(Modified="[-0-9]\+T[^.+]\+\).\+">/\1">/'
    else
        # supress "complysh:module" attribute while not in debug mode, and set time to XML format
        source $MODULE_CMD | sed -e 's/ complysh:module="[^"]*"//g' | sed -e 's/\(Modified="[-0-9]\+T[^.+]\+\).\+">/\1">/'
    fi
    RC=$?
    echo_log 'DEBUG' "MODULE RC $RC:" 
    if [ "$RC" -ne "0" ]; then
        echo_log 'FATAL' "EXEC_CMD LINE `caller`" \"$MODULE_CMD\"
    fi
    return $RC
}

# Replaces chars with XML-compatible entities
function quotemeta () {
    LINE="$@"
    LINE="${LINE//&/&amp;}"
    LINE="${LINE//</&lt;}"
    LINE="${LINE//>/&gt;}"
    LINE="${LINE//\"/&quot;}"
    LINE="${LINE//"'"/&apos;}"
    printf '%s' "$LINE"
} 

# Outputs XML section
function section() {
    LEADING_SPACES_COUNT=$1
	shift
    SECTION_NAME=$1
	shift
	DATA=$@
    echo_log 'DEBUG' "Generating section $SECTION_NAME with $LEADING_SPACES_COUNT spaces..."
    printf '%-'$LEADING_SPACES_COUNT's' ' '
    echo -n "<$SECTION_NAME>"
	while read -r line ; do quotemeta "$line"; done <<< "$DATA" 
    echo "</$SECTION_NAME>" 
}

# outputs string with leading spaces
function tag() {
    LEADING_SPACES_COUNT=$1
	shift
    DATA="$@"
    printf '%-'$LEADING_SPACES_COUNT's' ' '
    printf '%s' "$DATA"
    echo
}

# Removes leading and trailing spaces
function chomp() {
    LINE="$@"
    #LINE="${LINE//^\s*/}"
    #LINE="${LINE// \s*$/}"
    #printf '%s' "$LINE"
    echo "$(echo -e "${@}" | sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]$//')"
}

function entry_cdata() {
    LINE=`chomp "$@"`
    tag 6 `printf '<Line><![CDATA[%s]]></Line>' "$LINE"`
}

# Converts number of bits into subnet mask,
# since RHEL7+ 'ip a' outputs CIDR only
function cidr2mask() {
    local i mask=""
    local full_octets=$(($1/8))
    local partial_octet=$(($1%8))

    for ((i=0;i<4;i+=1)); do
	if [ $i -lt $full_octets ]; then
	    mask+=255
	elif [ $i -eq $full_octets ]; then
	    mask+=$((256 - 2**(8-$partial_octet)))
	else
	    mask+=0
	fi  
	test $i -lt 3 && mask+=.
    done

    echo $mask
}

# Translates hexadecimal number into CIDR
function hex2cidr() {
    HEX="$1"
    HEX="${HEX//0x/}"

    D2B=({0..1}{0..1}{0..1}{0..1})

    BITS_COUNT_MASK=0
    for ((i=0;i<${#HEX};i+=1)); do
        CHAR=${HEX:$i:1}
        DEC=$((16#$CHAR))
        BIN=${D2B[DEC]}
        for ((k=0;k<${#BIN};k+=1)); do
                BIT=${BIN:$K:1}
                if [ "$BIT" -eq 1 ]; then
                        BITS_COUNT_MASK=$((BITS_COUNT_MASK+1))
                else
                        #echo $BITS_COUNT_MASK
                        #return 0
                        k=${#BIN}
                        i=${#HEX}
                fi
        done
    done
    echo $BITS_COUNT_MASK
}

