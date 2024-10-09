
source incl/functions.sh

echo_log 'INFO' 'Checking root path integrity...'


DATA=`
for x in $(echo $PATH | tr ":" " ") ; do 
    if [ -d "$x" ] ; then 
        ls -ldH "$x" | awk ' 
            $9 == "." {print "PATH contains current working directory (.)"} $3 != "root" {print $9, "is not owned by root"} substr($1,6,1) != "-" {print $9, "is group writable"} substr($1,9,1) != "-" {print $9, "is world writable"}' 
    else 
        echo "$x is not a directory" 
    fi 
done`

# prevent '*' sign expansion
set -f

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Root User Path Problems" Location="~" Type="TXT">
EOS1

while read -r LINE; do
    entry_cdata "$LINE"
done <<< "$DATA"

cat <<-EOS2
    </ConfigData>
EOS2

