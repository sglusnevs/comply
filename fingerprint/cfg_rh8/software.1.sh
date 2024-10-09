
source incl/functions.sh

echo_log 'INFO' 'Gathering software info...'

cat <<-EOS1
    <Software>
EOS1


export IFS=';'
rpm -qa --queryformat "%{NAME};%{VERSION};%{VENDOR};%{URL};%{SUMMARY}\n" | while read NAME VERSION VENDOR URL SUMMARY; do
    SUMMARY=$(chomp `quotemeta $SUMMARY`)
    NAME=$(chomp `quotemeta $NAME`)
    VERSION=$(chomp `quotemeta $VERSION`)
    VENDOR=$(chomp `quotemeta $VENDOR`)
    URL=$(chomp `quotemeta $URL`)
    echo_log 'DEBUG' "Parsing software line '$NAME' => '$VERSION', '$VENDOR', '$URL', '$SUMMARY'"
    tag 9 `printf '<Product Version="%s">' $VERSION`
    section 11 'Name' $NAME
    section 11 'Vendor' $VENDOR
    section 11 'URLInfoAbout' $URL
    section 11 'Description' $SUMMARY
    tag 9 '</Product>'
done 

cat <<-EOS2
    </Software>
EOS2
