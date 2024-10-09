
source incl/functions.sh

echo_log 'INFO' 'Gathering configuration for firewalld default zone...'

# prevent '*' sign expansion
set -f

DEF_ZONE=`grep DefaultZone /etc/firewalld/firewalld.conf |awk -F= '{print $2}'`
LOCATION=/etc/firewalld/zones/${DEF_ZONE}.xml

cat <<-EOS1
    <ConfigData Label="Firewalld Default Zone Rules" Location="$LOCATION" Type="XML">
EOS1

    grep -v '<?xml' $LOCATION | while read LINE; do
        tag 8 $LINE
    done

cat <<-EOS2
    </ConfigData>
EOS2
