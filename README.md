# Certificati server SSL con Debian: una proposta

## Per quali servizi/demoni servono i certificati server
* apache2;
* exim4 (quando passa tramite uno smarthost che autentica i satelliti con i certificati);
* activemq (però chiave e certificato debbono essere in formati PKCS12);
* filebeat (inoltro dei log via TCP/SSL verso un collettore ELK);
* samba (non riesce a condividere la chiave).

## Come Debian gestisce di default la condivisione dei certificati
Condividere la stessa chiave privata SSL tra più servizi crea problemi di ownership del file. 
Di default la soluzione Debian è il gruppo ```ssl-certs```. 

## Usare ACME quando possibile
Se un certo server ha solo apache2 ed exim4, la cosa migliore è usare il 
protocollo ACME (lo stesso di letsencrypt) sugli endpoint sectigo. 
Vedi ad esempio questo [playbook ansible](https://github.com/francescm/acme-ansible-debian-sectigo).

Diventa possibile fare ogni cosa con ACME grazie agli 
hook di post-install, che sono degli script invocati 
al rinnovo.

## Chiave privata
Per creare la chiave si può usare uno degli script:
* tcs_tool.rb per una chiave RSA;
* ec_tool.rb per una chiave EC;
* ec_tool_san_ext.rb per chiave EC e nomi alternativi 
da linea di comando così la interfaccia web non li 
chiede di nuovo.

Usare gli script permette di avere tutte le chiavi 
su una sola macchina, magari su una partizione cifrata.

Quando la chiave privata deve essere condivisa con exim4 la mia soluzione è 
nello script ```install.sh``` (in breve si settano anche delle acl).

## Certificato pubblico
Per scaricare il certificato pubblico vedi lo 
script ```get_ssl.sh```.

Il problema è la rotazione dei file che è annuale. Se si fa il rinnovo la chiave 
privata non cambia. Se i servizi usano il certificato:

    /etc/ssl/cert/fqdn-del-host.pem

che è un soft link al certificato vero è proprio che è:

    /etc/ssl/certs/fqdn-del-host-numero-certificato.pem

si riesce a gestire il rollover e mantenere lo storico.

## Activemq
Il problema è la passphrase del PKCS12. Se uno la 
sa, lo script ```create_pkcs12.rb``` crea il file.