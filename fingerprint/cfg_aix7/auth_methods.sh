
source incl/functions.sh

LOCATION=/usr/lib/security/methods.cfg

echo_log 'INFO' 'Gathering authentication methods settings...'

# prevent occational asterisk in config be expanded to list of files
set -f

cat <<-EOS1
    <ConfigData Label="Authentication Methods Config" Location="$LOCATION" Type="INI">
EOS1

PREFIX=
grep -v '^\*' $LOCATION | grep -E -v '^[	 ]*$' | while IFS='=' read -r K V; do
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
