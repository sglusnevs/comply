
source incl/functions.sh

echo_log 'INFO' 'Gathering certificates...'

# we use temporary file to store certificate data
TEMP_FILE=$IST_PATH/cert.tmp

echo_log 'DEBUG' "Certificates tempfile $TEMP_FILE"

cat <<-EOS1
    <Certificates>
EOS1

CERT_PATH=`cat $CFG_PATH/certs.cfg`

find $CERT_PATH -name "*.pem" -o -name "*.crt" > $CERT_LIST

if [ ! -s "$CERT_LIST" ]; then

    echo_log 'WARN' "Cert pathes '$CERT_PATH' do not contain any certificate files"
else

    cat $CERT_LIST | while read CERT_STORE; do

            CERT_STORE=$(quotemeta $CERT_STORE)

            echo_log 'DEBUG' "Found certificate file $CERT_STORE"

            tag 7 `printf '<CertStore Location="%s" Name="%s">' "$CERT_STORE" "$(basename $CERT_STORE)"`

            # enumerate certificates
            IDX=0
            LINE_NUM=0
            openssl crl2pkcs7 -nocrl -certfile $CERT_STORE | openssl pkcs7 -print_certs -text -noout > $TEMP_FILE
            CERT_COUNT=($(grep 'Certificate:' $TEMP_FILE | wc -l))
            FILE_LINES=($(wc -l $TEMP_FILE))
            cat $TEMP_FILE | while read LINE; do
                    LINE_NUM=$((LINE_NUM+1))
                    # new certificate started
                    if [[ $LINE_NUM = $FILE_LINES || "$LINE" =~ 'Certificate:' ]]; then
                        if [[ $IDX > 0 ]]; then
                            # not the first one, close previous
                            tag 9 '</Cert>'
                            echo_log 'DEBUG' 'Cert ended'
                        fi
                        echo_log 'DEBUG' 'Cert started #'$IDX
                        if [[ ! -z "$C_VERSION" ]]; then
                            # print data of previous certificate
                            C_TAG=`printf '<Cert Version="%s" Issuer="%s" SubjectName="%s" Serial="%s" KeyAlgorithm="%s" Format="X509" NotBefore="%s" NotAfter="%s">' "$(quotemeta $C_VERSION)" "$(quotemeta $C_ISSUER)" "$(quotemeta $C_SUBJECT)" "$(quotemeta $C_SERIAL)" "$(quotemeta $C_KEY_ALGO)" "$(quotemeta $C_NOT_BEFORE)" "$(quotemeta $C_NOT_AFTER)"`
                            tag 9 $C_TAG
                            echo_log 'INFO' "Cert extracted from $CERT_STORE #$((IDX+1)) of $CERT_COUNT"
                            tag 11 `printf '<PublicKey OIDFriendly="%s">' "$(quotemeta $C_KEY_ALGO)"`
                            tag 13 '<RSAKeyValue>'
                            tag 15 '<Modulus>'$C_MODULUS'</Modulus>'
                            tag 15 '<Exponent>'$C_KEY_EXP'</Exponent>'
                            tag 13 '</RSAKeyValue>'
                            tag 11 '</PublicKey>'
                            IDX=$((IDX+1))
                        fi
                    fi
                    # extract serial number records
                    if [[ "$C_NXT_SERIAL" == 1 ]]; then
                        C_SERIAL=$(chomp $LINE)
                        C_NXT_SERIAL=0
                        echo_log 'DEBUG' 'Serial NEXT line found:' $C_SERIAL
                        continue
                    fi
                    # extract modulus records
                    if [[ "$C_NXT_MODULUS" == 1 ]]; then
                        if [[ "$LINE" =~ ^[:0-9a-f]+$ ]]; then
                            C_MODULUS=$C_MODULUS$(chomp $LINE)
                            echo_log 'DEBUG' 'Modulus NEXT line found:' $LINE
                            continue
                        else
                            C_NXT_MODULUS=0
                            echo_log 'DEBUG' 'Modulus found:' $C_MODULUS
                        fi
                    fi

                    if [[ "$LINE" =~ 'Version:' ]]; then
                        DATA=($LINE); C_VERSION=$(chomp ${DATA[1]})
                    elif [[ "$LINE" =~ 'Issuer:' ]]; then
                        DATA=($LINE); C_ISSUER=$(chomp ${DATA[@]:1})
                    elif [[ "$LINE" =~ 'Public Key Algorithm:' ]]; then
                        DATA=($LINE); C_KEY_ALGO=$(chomp ${DATA[3]})
                    elif [[ "$LINE" =~ 'Exponent:' ]]; then
                        DATA=($LINE); C_KEY_EXP=$(chomp ${DATA[1]})
                    elif [[ "$LINE" =~ 'Not Before:' ]]; then
                        DATA=($LINE); C_NOT_BEFORE=$(chomp ${DATA[@]:2})
                    elif [[ "$LINE" =~ 'Not After' ]]; then
                        DATA=($LINE); C_NOT_AFTER=$(chomp ${DATA[@]:3})
                    elif [[ "$LINE" =~ ^Subject: ]]; then
                        DATA=($LINE); C_SUBJECT=$(chomp ${DATA[@]:1})
                    elif [[ "$LINE" =~ ^Modulus[^:]*: ]]; then
                        C_NXT_MODULUS=1
                        C_MODULUS=''
                    elif [[ "$LINE" =~ 'Serial Number:' ]]; then
                        DATA=($LINE); C_SERIAL=$(chomp ${DATA[2]})
                        if [ -z "$C_SERIAL" ]; then
                            C_NXT_SERIAL=1
                            echo_log 'DEBUG' 'Serial data expected next line'
                        else
                            echo_log 'DEBUG' 'Serial data found sameline:' $C_SERIAL ' extracted from ' $LINE
                        fi
                    fi

                    # close last certificate if any processed
                    if [[ $LINE_NUM = $FILE_LINES && $LINE_NUM > 1 ]]; then
                            tag 9 '</Cert>';
                            echo_log 'DEBUG' 'Last cert ended'
                    fi
            done

            tag 7 '</CertStore>'
    done  
fi

cat <<-EOS2
    </Certificates>
EOS2

rm -f $TEMP_FILE 
