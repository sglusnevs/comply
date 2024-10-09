
## Comply IT security audit'rs toolkit

Comply is a tool moduler tool that gathers security-related information from various Unix operating systems and packs it into an XML file. This file is then encrypted with auditor's public key to provide iprovacy, integrity and non-repudiation and is transferred to auditor's desktop. The results can be compared with previous audits, as well as specific exerpts can be analyzed for current security state.

Supported OS are:

- AIX 7
- RHEL 7
- RHEL 8
- RHEL 9 (CIS Benchmarks)
- Sun Solaris 10
- Sun Solaris 11 


## How to use

1. Generate keypair to encrypt the audit results

```
# cd priv/
# ./genkeys
```

Keys will be placed under:
- priv/comply.key (private) and 
- release/keys/comply.crt (public)

2. Prepare fingerprinting tool to be sent to the machine to be audited

The 'release' folder is intended to be sent to the executing party together with generated release/keys/comply.crt

```
# tar cvfz release.tgz release/
```

3. At the machine to be audited, decompress and execute the tool

```
# gunzip < release.tgz | tar xf – 
# cd release
# chmod +x comply
# ./comply
Success: <hostname>.tgz
```

4. Transfer the <hostname>.tgz to the auditor's machine

5. At the auditor's machine decompress and decrypt the results 

```
# cd priv
# tar xvfz <hostname>.tgz
ist_<architecture> folder is created
# ./decrypt -in ist_rh8/audit.enc -out audit.xml -priv comply.key -hash ist_rh8/audit.sha1 -key ist_rh8/key.enc
# more audit.xml
```
