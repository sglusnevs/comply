
source incl/functions.sh

echo_log 'INFO' 'Gathering nftables runtime configuration...'

tag 4 '<ConfigData complysh:module="'$MODNAME'" Label="nftables ruleset" Location="nft list ruleset" Type="XML">'
tag 6 '<Data>'
nft list ruleset | awk '
/^table/ { if (chain) print "          </chain>"; if (table) print "        </table>"; table=$3; chain=""; proto = $2; print "        <table name=\""table"\" proto=\""proto"\">"; next;  }
/^\s*chain/ { if (chain) print "          </chain>"; chain=$2; print "          <chain name=\""chain"\">"; next; }
/^\s*}/ { next; }
!/^$|^\s*\#|^\s*;/ { gsub(/^\s*/, "", $0); print "            <Line><![CDATA["$0"]]></Line>"; } 
END { if (chain) print "          </chain>"; if (table) print "        </table>"; }
'
tag 6 '</Data>'
tag 4 '</ConfigData>'

