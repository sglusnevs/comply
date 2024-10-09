
source incl/functions.sh

echo_log 'INFO' 'Gathering /etc/firewalld/direct.xml...'

# prevent '*' sign expansion
set -f

cat <<-EOS1
    <ConfigData Label="Firewalld direct config" Location="/etc/firewalld/direct.xml" Type="XML">
EOS1

    grep -v '<?xml' /etc/firewalld/direct.xml | while read LINE; do
        tag 8 $LINE
    done

cat <<-EOS2
    </ConfigData>
EOS2
