
source incl/functions.sh

echo_log 'INFO' 'Gathering gpgcheck settings...'

BASEDIR='/etc/yum.repos.d'

MAIN_CONFIG=/etc/yum.conf

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Main yum Gpgcheck Config" Location="$MAIN_CONFIG" Type="WININI">
EOS1

GPGCHECK_MAIN_DEFAULT=0
GPGCHECK_FOUND=

DATA=`grep -E -v '^$|^\s*\#|^\s*;' $MAIN_CONFIG`

while IFS='=' read -r K V; do
    if [[ $K == \[main\] ]]; then
        SECTION=$(echo $K | sed 's/[^a-zA-Z0-9]//g')
        tag 6 `printf '<Section Name="%s">' "$(quotemeta $SECTION)"`
    elif [[ $K == *gpgcheck* ]] && [ ! -z "$SECTION" ]; then
        tag 8 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
        tag 6 '</Section>'
        GPGCHECK_MAIN_DEFAULT=$V
        GPGCHECK_FOUND=1
    fi
done <<< "$DATA"

# missed gpgcheck key, set default value to zero
if [ -z $GPGCHECK_FOUND ]; then
    if [ -z "$SECTION" ]; then
        # section not found, default to 0
        tag 8 '<Entry Key="gpgcheck" Value="0"/>'
    else
        # section has been found, still default to zero
        tag 8 '<Entry Key="gpgcheck" Value="0"/>'
        tag 6 `printf '</Section>'`
    fi
fi

cat <<-EOS2
    </ConfigData>
EOS2

ls $BASEDIR | while read REPO; do 

FILENAME="$BASEDIR/$REPO"

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="$REPO Gpgcheck Config" Location="$FILENAME" Type="WININI">
EOS1

SECTION=

grep -E -v '^$|^\s*\#|^\s*;' $FILENAME | while IFS='=' read K V; do
    if [[ $K == \[* ]]; then
        if [ ! -z "$SECTION" ]; then
            # section closed without gpgcheck key found, set default value from main config file
            tag 8 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $GPGCHECK_MAIN_DEFAULT)"`
            tag 6 `printf '</Section>'`
        else
            SECTION=$(echo $K | sed 's/[^a-zA-Z0-9]//g')
            tag 6 `printf '<Section Name="%s">' "$(quotemeta $SECTION)"`
        fi
    elif [[ $K == *gpgcheck* ]] && [ ! -z "$SECTION" ]; then
        tag 8 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
        tag 6 `printf '</Section>'`
        SECTION=
    fi
done 

cat <<-EOS2
    </ConfigData>
EOS2

done
