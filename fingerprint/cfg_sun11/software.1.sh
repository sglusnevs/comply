
source incl/functions.sh

echo_log 'INFO' 'Gathering software info...'

cat <<-EOS1
    <Software>
EOS1


pkginfo -l | while read LINE; do
    DATA=($LINE)
    K=`chomp ${DATA[0]}`
    V=`chomp ${DATA[@]:1}`
    echo_log 'DEBUG' "Parsing software line '$LINE'"
    case "$K" in
        'VERSION:')
		VERSION=`quotemeta "$V"`
                echo_log 'DEBUG' "Version found: $V"
        ;;
        'NAME:')
		NAME=`quotemeta "$V"`
                echo_log 'INFO' "Processing software package '$V'"
        ;;
        'DESC:')
		DESC=`quotemeta "$V"`
                echo_log 'DEBUG' "Description found: $V"
        ;;
        'VENDOR:')
		VENDOR=`quotemeta "$V"`
                echo_log 'DEBUG' "Vendor found: $V"
        ;;
        '')
                echo_log 'DEBUG' "Generating section Product"
                tag 9 `printf '<Product Version="%s">' "$VERSION"`
		section 13 'Name' "$NAME"
		section 13 'Vendor' "$VENDOR"
		section 13 'Description' "$DESC"
                tag 9 '</Product>'
		# avoid using current version on next package when its own description misses one
                VERSION='n/a'
        ;;
    esac
done 

cat <<-EOS2
    </Software>
EOS2
