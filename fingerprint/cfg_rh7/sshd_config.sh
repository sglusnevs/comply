
source incl/functions.sh

echo_log 'INFO' 'Gathering SSH Server Settings...'

# prevent '*' sign expansion
set -f

LOCATION=/etc/ssh/sshd_config

cat <<-EOS1
    <ConfigData Label="SSH Server Config" Location="$LOCATION" Type="INI">
EOS1

grep -v '^$\|^\s*\#' $LOCATION | while read -r LINE; do
    DATA=($LINE); 
    # get first word of config file as key
    K=$(chomp `quotemeta ${DATA[0]}`)
    # get the rest as value -- to handle strings like "SendEnv LC_IDENTIFICATION LC_ALL LANGUAGE"
    V=$(chomp `quotemeta ${DATA[@]:1}`)
    tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$K" "$V"`
done 

cat <<-EOS2
    </ConfigData>
EOS2
