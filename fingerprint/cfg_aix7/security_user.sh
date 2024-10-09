
source incl/functions.sh

LOCATION=/etc/security/user

echo_log 'INFO' 'Gathering user policy settings...'

# prevent occational asterisk in config be expanded to list of files
set -f

cat <<-EOS1
    <ConfigData Label="User Policy Config" Location="$LOCATION" Type="INI">
EOS1

PREFIX=
grep -v '^\*' $LOCATION | grep -v '^$' | while IFS='=' read -r K V; do
    K=$(chomp $K)
    V=$(chomp $V)
    if [[ "$K" =~ :$ ]]; then
	PREFIX=$K
    else
    	tag 6 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $PREFIX$K)" "$(quotemeta $V)"`
    fi

done

cat <<-EOS2
    </ConfigData>
EOS2
