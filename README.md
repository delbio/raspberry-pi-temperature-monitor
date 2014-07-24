Monitor Raspberry Pi temperature
================================

Ogni 6 minuti rileva la temperatura della raspberry e la salva il record in una tabella, se la temperature supera una soglia massima, invia una email a ogni destinatario contenuto in un file

Configurazione di sendmail
==========================

Per configurare il comando sendmail, di modo che invii email a nome del vostro account gmail, seguite questa guida

http://linuxconfig.org/configuring-gmail-as-sendmail-email-relay

Installazione di MySQL
=======================

Seguire questa guida per l'installazione di MySQL su raspberry

http://www.emcu.it/RaspBerryPi/RaspBerryPi.html#Installare%20il%20data%20base%20MySQL
  
Usage
=====

Per notificare  il superamento della temperatura massima via mail ad un insieme di indirizzi email, creare un file con la lista di destinatari desiderati:

    touch destinatari.txt
    echo "email@dominio.it" >> destinatari.txt
    echo "email1@dominio.com" >> destinatari.txt

Il seguente script inizializzerà il crontab che, ogni 6 minuti, rileverà la temperatura, la salverà come record in una tabella e se la temperatura supera la soglia massima invia mail a tutti i destinatari:

    bash init_crontab.sh db-config-cfg $(pwd)/destinatari.txt
    bash init_crontab.sh db-config-cfg $(pwd)/destinatari.txt 60

Se non si imposta nessuna soglia massima, il terzo argomento, il valore di default è 65 °C    
Nota: eseguire il comando precedente nella cartella del progetto, per rispettare i riferimenti tra script

Maggiori informazioni
=====================
Per Maggiori informazioni su crontab:

http://guide.debianizzati.org/index.php/Utilizzo_del_servizio_di_scheduling_Cron#Stringhe_speciali
http://it.wikipedia.org/wiki/Crontab
