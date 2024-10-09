
source incl/functions.sh

echo_log 'INFO' 'Gathering firewalld configuration...'

tag 4 '<ConfigData complysh:module="'$MODNAME'" Label="firewall config" Location="firewall-ctl" Type="WININI">'
tag 6 '<Section Name="firewalld">'
tag 8 '<Entry Key="default-zone" Value="'$(quotemeta `firewall-cmd --get-default-zone`)'"/>'
tag 6 '</Section>'
tag 4 '</ConfigData>'


