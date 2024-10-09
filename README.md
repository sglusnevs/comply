# Usage

## Generate keypair to encrypt the audit results

```
# cd priv/
# ./genkeys
```

Keys will be placed under:
- priv/comply.key (private) and 
- release/keys/comply.crt (public)

## Prepare fingerprinting tool to be sent to the audited machine

The 'release' folder is intended to be sent to the executing party together with generated release/keys/comply.crt

```
# tar cvfz release.tgz release/
```

## At the machine to be audited

```
# gunzip < release.tgz | tar xf – 
# cd release
# chmod +x comply
# ./comply
Success: <hostname>.tgz
```

## At the auditor's machine to analyze the results

```
# cd priv
# tar xvfz <hostname>.tgz
ist_<architecture> folder is created
# ./decrypt -in ist_rh8/audit.enc -out audit.xml -priv comply.key -hash ist_rh8/audit.sha1 -key ist_rh8/key.enc
# more audit.xml
```
