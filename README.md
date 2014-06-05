Backuppc
========

Based on Backuppc project (http://backuppc.sourceforge.net/), eNovance are developing some features for internal needs.

#Backuppc 3.3.0


#New features


INSTALL
=======

#Server

##Requirements
```bash
   adduser backuppc

   apt-get install libdbi-perl libfile-rsyncp-perl libfile-rsyncp-perl
```


##configure.pl
```bash
   adduser backuppc

   ./configure.pl --install-dir /opt/backuppc --cgi-dir /opt/backuppc/cgi-bin --config-dir /etc/backuppc --data-dir /home/backuppc --html-dir /opt/backuppc/cgi-bin/images --html-dir-url /backuppc --html-dir-url /cgi-bin/images
   ln -s /etc/backuppc /etc/backuppc/pc
   cd /opt/backuppc/cgi-bin
   ln -s BackupPC_Admin index.cgi
   chown backuppc:www-data *
   chmod 6554 index.cgi
```

##initd

```bash
  cp init.d/debian-backuppc /etc/init.d/backuppc
  chmod +x /etc/init.d/backuppc
```



##Generate htaccess
If you don't use ldap access

```bash
   htpasswd -c /etc/backuppc/BackupPC.users backuppc
```

##Generate ssh-key

```bash
   su - backuppc
   ssh-keygen -t rsa -C "backuppc"
```

##Configuration apache

Activer les modules si besoin
```bash
   a2enmod rewrite ssl
   apt-get install cronolog
```

Configuration vhost
```bash
<VirtualHost *:80>

    ServerName localhost
    ServerAdmin admin@enovance.com

    RewriteEngine on
    RewriteLogLevel 1
    RewriteCond %{SERVER_PORT} !^443$
    RewriteCond %{HTTP_HOST}   !^localhost$
    RewriteRule ^/(.*) https://%{SERVER_NAME}/$1 [L,R]

    ErrorLog ${APACHE_LOG_DIR}/error.log
    LogLevel warn
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

<VirtualHost *:443>
    ServerName mybackuppc.domaine.com
    ServerAdmin webmaster@localhost

    DocumentRoot /opt/backuppc/cgi-bin
    Alias           /backuppc         /opt/backuppc/cgi-bin/images
    ScriptAlias     /BackupPC_Admin         /opt/backuppc/cgi-bin/BackupPC_Admin

    SSLEngine on 
    SSLProtocol +SSLv3 +TLSv1 -SSLv2
    SSLCipherSuite HIGH:MEDIUM
  
    SSLCertificateKeyFile    /opt/enovance/ssl/star_enovance_com.key
    SSLCertificateFile       /opt/enovance/ssl/star_enovance_com.crt
    SSLCertificateChainFile  /opt/enovance/ssl/DigiCertCA.crt

    <Directory  /opt/backuppc/cgi-bin >
     AllowOverride None                                                                  
     Options ExecCGI FollowSymlinks
     AddHandler cgi-script .cgi
     DirectoryIndex index.cgi

     order deny,allow
     allow from all

     AuthType Basic
     AuthUserFile /etc/backuppc/BackupPC.users
     AuthName "BackupPC Community Edition Administrative Interface"

     require valid-user
    
    </Directory>


        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

    ErrorLog  "|/usr/bin/cronolog /var/log/apache2/mybackuppc.domaine.com/error-%Y%m%d.log"
    CustomLog "|/usr/bin/cronolog /var/log/apache2/mybackuppc.domaine.com/access-%Y%m%d.log" combined               
    CustomLog "|/usr/bin/cronolog /var/log/apache2/mybackuppc.domaine.com/ssl_request-%Y%m%d.log"  "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"
</VirtualHost>

```

##TODO
- Run apache with backuppc user
- Add details about ldap config

##Optimisation
Disable updatedb / locate on /home/backuppc
```bash
   vim /etc/updatedb.conf
   PRUNEPATHS="/tmp /var/spool /media /home/backuppc"
```
