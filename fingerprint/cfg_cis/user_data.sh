
source incl/functions.sh

REFMOD=$(basename $BASH_SOURCE | sed -e 's/\.sh$//')

LOCATION_PASSWD=/etc/passwd
LOCATION_SHADOW=/etc/shadow

# prevent '*' sign expansion
set -f

echo_log 'INFO' "Gathering extended user info..."

cat <<-EOS1
    <ConfigData complysh:module="$MODNAME" Label="Users shell and password expiry info" Location="/etc/passwd and /etc/shadow" Type="WININI">
EOS1

cut -d: -f1,7 --output-delimiter=' ' $LOCATION_PASSWD | while read USR SHL; do 

    LAST_PWD_CHANGE=$(chage --list $USR | grep '^Last password change' | cut -d: -f2); 
    
    tag 6 `printf '<Section Name="%s">' "$(quotemeta $USR)"`
    tag 10 `printf '<Entry Key="SHELL" Value="%s" />' "$(quotemeta $SHL)"`
    tag 10 `printf '<Entry Key="PwdLastChanged" Value="%s" />' "$(quotemeta $LAST_PWD_CHANGE)"`
    tag 6 '</Section>'
done

cat <<-EOS2
    </ConfigData>
EOS2

