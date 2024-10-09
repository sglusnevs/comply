
source incl/functions.sh

MODNAME=custom

echo_log 'INFO' 'Gathering custom configuration data...'

CFG_FILE="$CFG_PATH/custom.xml"

XML_INCLUSION_LEVEL_MAX=10

function parse_custom_xml() {

    FILENAME_XML=$1

    RECURSION_DEPTH=$2

    #echo_log 'DEBUG' "Called parse_custom_xml('$FILENAME_XML', '$RECURSION_DEPTH')"

    if [ ! -f "$FILENAME_XML" ]; then
        echo_log 'WARNING' "Custom XML configuration file $FILENAME_XML not found"
        return
    fi

    if [ "$RECURSION_DEPTH" -ge "$XML_INCLUSION_LEVEL_MAX"  ]; then
        echo_log 'ERROR' "Trying to read custom configuration file $FILENAME_XML: maximal recursion level exceeded"
        return
    fi

    cat $FILENAME_XML | grep -iE '<IncludeDefinition |<ConfigData |<Files ' | while read LINE_RELEVANT; do

        echo "$LINE_RELEVANT" | awk -F 'Location=|href=|Path=' '{ print $2 " " $1 }' | awk -F\" '{ print $2 " " $0 }' | while read FILENAME RELATION; do 

            # Check if this is actual config file to read or yet another XML file included 
            echo $RELATION | grep -i '<IncludeDefinition' > /dev/null 2>&1

            if [ $? -eq 0 ]; then

                echo_log 'DEBUG' "IncludeDefinition found for '$FILENAME' in $FILENAME_XML..."

                ((RECURSION_DEPTH=RECURSION_DEPTH+1))

                parse_custom_xml "$CFG_PATH/$FILENAME" $RECURSION_DEPTH

                continue
            fi

            LOCATION="$FILENAME"

            # extract delimiter
            DELIMITER=`echo -n "$LINE_RELEVANT" | awk -F 'ElementDelimiter=' '{print $2}' | awk -F\" '{print $2}'`

            if [ ! -z "$DELIMITER" ]; then

                echo_log 'DEBUG' "ElementDelimiter definition found for '$FILENAME': '$DELIMITER'"
            fi

            # extract type 
            TYP=`echo -n "$LINE_RELEVANT" | awk -F 'Type=' '{print $2}' | awk -F\" '{print $2}'`

            if [ ! -z "$TYP" ]; then

                echo_log 'DEBUG' "Type definition found for '$FILENAME': '$TYP'"
            fi

            # extract depth 
            DEPTH=`echo -n "$LINE_RELEVANT" | awk -F 'Depth=' '{print $2}' | awk -F\" '{print $2}'`

            if [ ! -z "$DEPTH" ]; then

                echo_log 'DEBUG' "Depth found for '$FILENAME': '$DEPTH', overwritting Type"

                # overwrite type for easier case statement later

                TYP=FILES
            fi



            case $TYP in 
                XML)

                    echo_log 'INFO' "Reading system configuration file '$LOCATION'..."

                    if [ ! -f "$LOCATION" ]; then
                        echo_log 'ERROR' "System configuration file $FILENAME included in 'Location' in '$FILENAME_XML', but not found"
                        return
                    fi

                    # Take config line 1:1 from configuration file but add complysh:module here
                    echo "    $LINE_RELEVANT" | sed -e 's|\s*/\s*>$|>|' | sed -e "s/<ConfigData/<ConfigData complysh:module=\"$MODNAME\"/"

                    tag 6 '<Data>'
                    # swap IFS to repserve leading spaces in XML
                    OIFS=$IFS
                    IFS=
                    # output everything except for opening tag
                    grep -v '<?xml' $LOCATION | while read LINE; do
                        tag 8 $LINE
                    done
                    IFS=$OIFS
                    tag 6 '</Data>'
                    tag 4 '</ConfigData>'
                ;;

                INI)
                    if [ -z "$DELIMITER" ]; then
                        echo_log 'ERROR' "ElementDelimiter attribute is mandatory for INI files, but no valid definition found in the line '$LINE_RELEVANT'"
                        continue
                    fi

                    echo_log 'INFO' "Reading system configuration file '$LOCATION'..."

                    if [ ! -f "$LOCATION" ]; then
                        echo_log 'ERROR' "System configuration file $FILENAME included in 'Location' in '$FILENAME_XML', but not found"
                        return
                    fi

                    # Take config line 1:1 from configuration file but add complysh:module here
                    echo "    $LINE_RELEVANT" | sed -e 's|\s*/\s*>$|>|' | sed -e "s/<ConfigData/<ConfigData complysh:module=\"$MODNAME\"/"

                    DATA=`grep -E -v '^$|^\s*\#|^\s*;' $LOCATION`
                    while IFS="$DELIMITER" read K V; do
                        tag 8 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
                    done <<< "$DATA"

                    tag 4 '</ConfigData>'
                ;;

                WININI)

                    echo_log 'INFO' "Reading system configuration file '$LOCATION'..."

                    if [ ! -f "$LOCATION" ]; then
                        echo_log 'ERROR' "System configuration file $FILENAME included in 'Location' in '$FILENAME_XML', but not found"
                        return
                    fi

                    if [ -z "$DELIMITER" ]; then
                        echo_log 'ERROR' "ElementDelimiter attribute is mandatory for WININI files, but no valid definition found in the line '$LINE_RELEVANT'"
                        continue
                    fi

                    # Take config line 1:1 from configuration file but add complysh:module here
                    echo "    $LINE_RELEVANT" | sed -e 's|\s*/\s*>$|>|' | sed -e "s/<ConfigData/<ConfigData complysh:module=\"$MODNAME\"/" 

                    SECTION=

                    DATA=`grep -E -v '^$|^\s*\#|^\s*;' $LOCATION`
                    while IFS="$DELIMITER" read K V; do
                        if [[ $K == \[* ]]; then
                            if [ ! -z "$SECTION" ]; then
                                # section closed without any key found
                                tag 6 `printf '</Section>'`
                                SECTION=
                            fi
                            SECTION=$(echo "$K" | sed 's/[][]/ /g' ) # replace square brackets
                            tag 6 `printf '<Section Name="%s">' "$(quotemeta $SECTION)"`
                        elif [ ! -z "$SECTION" ]; then
                            tag 8 `printf '<Entry Key="%s" Value="%s"/>' "$(quotemeta $K)" "$(quotemeta $V)"`
                        fi
                    done <<< "$DATA"

                    if [ ! -z "$SECTION" ]; then
                        # close remaining section 
                        tag 6 `printf '</Section>'`
                    fi

                    tag 4 '</ConfigData>'
                ;;

                TXT)

                    echo_log 'INFO' "Reading system configuration file '$LOCATION'..."

                    if [ ! -f "$LOCATION" ]; then
                        echo_log 'ERROR' "System configuration file $FILENAME included in 'Location' in '$FILENAME_XML', but not found"
                        return
                    fi

                    # Take config line 1:1 from configuration file but add complysh:module here
                    echo "    $LINE_RELEVANT" | sed -e 's|\s*/\s*>$|>|' | sed -e "s/<ConfigData/<ConfigData complysh:module=\"$MODNAME\"/" 

                    DATA=`grep -E -v '^$' $LOCATION`
                    while read -r LINE; do
                        entry_cdata "$LINE"
                    done <<< "$DATA"
                    tag 4 '</ConfigData>'
                ;;

                FILES)

                    echo_log 'INFO' "Reading path '$LOCATION', depth $DEPTH..."

                    if [ ! -d "$LOCATION" ]; then
                        echo_log 'ERROR' "Path $FILENAME included in 'Path' in '$FILENAME_XML', but not found"
                        return
                    fi

                    tag 4 '<Files>'

                    DIR="$LOCATION"

                    echo_log 'INFO' "Gathering metadata for $DIR"
                    # test -L "$DIR" && DIR=$(dirname $DIR)`readlink $DIR`
                    # first, output directories, including entry itself
                    DIR_META=(`ls -ld $DIR`) 
                    tag 6 `printf '<Dir Path="%s" Owner="%s" Group="%s">' "$(quotemeta $DIR)" "$(quotemeta ${DIR_META[2]})" "$(quotemeta ${DIR_META[3]})"`
                    tag 10 `printf '<Access Type="X" Rights="%s">.</Access>' "$(quotemeta ${DIR_META[0]})"`
                    for TYPE in d f; do
                        IDX=0

                        # prepare
                        if [ "$DEPTH" -ge 0 ]; then
                            DEPTH_DEF="-maxdepth $DEPTH"
                        else
                            DEPTH_DEF=
                        fi

                        echo_log 'DEBUG' "Getting data of type "$TYPE" in '$DIR' max depth $DEPTH"

                        # find "$DIR" -type $TYPE $DEPTH_DEF -printf '%i %k %M %n %u %g %s %T+%Tz %p\n' | sed -e 's/+/T/' | while read INODE SIZE_KB RIGHTS HLINKS OWNER GROUP SIZE_BYTES MTIME FILENAME; do
                        find "$DIR" -type $TYPE $DEPTH_DEF -printf '%i %k %M %n %u %g %s %TY-%Tm-%TdT%TT %p\n' | while read INODE SIZE_KB RIGHTS HLINKS OWNER GROUP SIZE_BYTES MTIME FILENAME; do
                            # skip dir self
                            if [ "$IDX" = '0' -a "$FILENAME" = "$DIR" ]; then
                                continue
                            fi
                            BASENAME=`basename "$FILENAME"`
                            echo_log 'DEBUG' "Checking $FILENAME"
                            if [[ "$TYPE" = 'd' ]]; then
                                tag 10 `printf '<SubDir Path="%s" Owner="%s" Group="%s">' "$(quotemeta $BASENAME)" "$(quotemeta $OWNER)" "$(quotemeta $GROUP)"`
                                tag 14 `printf '<Access Type="X" Rights="%s">.</Access>' "$(quotemeta $RIGHTS)"`
                                tag 10 '</SubDir>'
                            elif [[ "$TYPE" = 'f' ]]; then
                                tag 10 `printf '<File Name="%s" Size="%d" Owner="%s" Group="%s" Modified="%s">' "$(quotemeta $BASENAME)" "$(quotemeta $SIZE_KB)" "$(quotemeta $OWNER)" "$(quotemeta $GROUP)" "$(quotemeta $MTIME)"`
                                tag 14 `printf '<Access Type="X" Rights="%s">.</Access>' "$(quotemeta $RIGHTS)"`
                                tag 10 '</File>'
                            fi
                            IDX=$((IDX+1))
                        done 
                    done
                    tag 6 '</Dir>'


                    tag 4 '</Files>'
                ;;
            esac

          done
    done
}

parse_custom_xml "$CFG_FILE" 1
