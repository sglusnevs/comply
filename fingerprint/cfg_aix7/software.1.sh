
source incl/functions.sh

echo_log 'INFO' 'Gathering software info...'

cat <<-EOS1
    <Software>
EOS1


export IFS=:
lslpp -lc all | while read LPP_PATH LPP_NAME LPP_VERSION LPP_X LPP_STATUS LPP_X LPP_DESC; do
    NAME=$(chomp `quotemeta $LPP_NAME`)
    SUMMARY=$(chomp `quotemeta $LPP_DESC`)
    # Vendor and URL cannot be determined here, s. https://www.ibm.com/developerworks/community/forums/html/topic?id=e71443d4-6681-422f-8cb6-30363ac3b11f
    VENDOR=''
    URL=''
    echo_log 'DEBUG' "Parsing software line '$NAME' => '$VERSION', '$VENDOR', '$URL', '$SUMMARY'"
    tag 9 `printf '<Product Version="%s">' $VERSION`
    section 11 'Name' $NAME
    section 11 'Description' $SUMMARY
    tag 9 '</Product>'
done 

cat <<-EOS2
    </Software>
EOS2
