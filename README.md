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

## ACME quando possibile

## Chiave private
Quando la chiave privata deve essere condivisa con exim4 la mia soluzione è 
nello script ```install.sh``` (in breve si settano anche delle acl).

## Certificato pubblico
Il problema è la rotazione dei file che è annuale. Se si fa il rinnovo la chiave 
privata non cambia. Se i servizi usano il certificato:

    /etc/ssl/cert/fqdn-del-host.pem

che è un soft link al certificato vero è proprio che è:

    /etc/ssl/certs/fqdn-del-host-numero-certificato.pem

si riesce a gestire il rollover e mantenere lo storico.

