Monitor Raspberry Pi temperature
================================

Ogni 6 minuti monitora la temperatura della rasp e salva la rilevazione in una tabella mysql;
salvata la rilevazione, contolla che il valore di temperatura non superi una soglia, definita dall'utente o default (65 °C) e nel caso venga superata, venie inviata una mail ad un insieme di mail.
Il limite di temperatura della rasp sono 70 °C 

Installazione di MySQL
=======================

Seguire questa guida per l'installazione di MySQL su raspberry

http://www.emcu.it/RaspBerryPi/RaspBerryPi.html#Installare%20il%20data%20base%20MySQL
  
Creazione di DB, Tabella e utente MySQL
=======================================

Eseguire i seguenti comandi per inizializzare il db e la tabella mysql

	bash init_db.sh db-config-sample.cfg

Se il programma mysql è installato, il terminale vi chiede se volete finalizzare l'inizializzazione del db, tabella e utente in mysql.

Se rispondete no o mysql non è installato allora verrà salvato un file: db_import.sql che rappresenta i comandi da eseguire in mysql per inizializzare il sistema correttamente.

Se risposndente Y allora il terminale vi chiede le credenziali: user name e password per accedere a mysql e poter creare: db, tabella e un nuovo utente con tutti i privilegi sul nuovo database da creare.

Potete controllare che tutto sia andato a buon fine entrando in mysql e digitando i seguenti comandi:

	mysql -u rasp -p

Eseguito l'accesso controllare che l'utente "rasp" abbia ottenuto i corretti privilegi:

	SHOW GRANTS;
	
    +------------------------------------------------------------------------+
    | Grants for rasp@localhost                                              |
    +------------------------------------------------------------------------+
    | GRANT USAGE ON *.* TO 'rasp'@'localhost' IDENTIFIED BY PASSWORD 'pass' |
    | GRANT ALL PRIVILEGES ON `rasp_monitor`.* TO 'rasp'@'localhost'         |
    +------------------------------------------------------------------------+

Per controllare la corretta costruzione della tabella "temperature":

	USE rasp_monitor;
	DESCRIBE temperature;
	
    +-------------+----------+------+-----+---------+----------------+
    | Field       | Type     | Null | Key | Default | Extra          |
    +-------------+----------+------+-----+---------+----------------+
    | id          | int(11)  | NO   | PRI | NULL    | auto_increment |
    | time        | datetime | NO   |     | NULL    |                |
    | temperature | int(11)  | NO   |     | NULL    |                |
    +-------------+----------+------+-----+---------+----------------+

La configurazione di MySQL è terminata correttamente.

Configurazione di sendmail
==========================

Per configurare il comando sendmail, di modo che invii email a nome del vostro account gmail, seguite questa guida

http://linuxconfig.org/configuring-gmail-as-sendmail-email-relay


Configurazione Notifica Via Email
=================================

Per notificare  il superamento della temperatura massima via mail ad un insieme di indirizzi email, creare un file con la lista di destinatari desiderati:

	touch destinatari.txt
	echo "email@dominio.it" >> destinatari.txt
	echo "email1@dominio.com" >> destinatari.txt

Automatizzazione via crontab
=============================

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
