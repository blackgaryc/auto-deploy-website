#/bin/bash

var_web_root="/var/www"
cert_root="/etc/ssl/private"

echo_default_conf(){
        if ! [ -w $var_web_root ];then
                echo "you need to run this in root"
                exit
        fi
        echo "<VirtualHost *:80>
        ServerName $1
        DocumentRoot $2
        ServerAdmin webmaster@localhost
        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" >/etc/apache2/sites-available/$1.conf
}
echo_ssl_conf(){
domain_name=`echo "$1" | grep -Ewo "(\w+\.\w+)$"`
if ! [ -d $cert_root/$domain_name ];then
        echo "$cert_root/$domain_name not found"
        exit
fi
echo "<IfModule mod_ssl.c>
        <VirtualHost _default_:443>
                ServerName $1
                ServerAdmin webmaster@localhost
                DocumentRoot $2
                ErrorLog \${APACHE_LOG_DIR}/error.log
                CustomLog \${APACHE_LOG_DIR}/access.log combined
                SSLEngine on
                SSLCertificateFile   $cert_root/$domain_name/full_chain.pem
                SSLCertificateKeyFile $cert_root/$domain_name/private.key
                <FilesMatch \"\.(cgi|shtml|phtml|php)$\">
                                SSLOptions +StdEnvVars
                </FilesMatch>
                <Directory /usr/lib/cgi-bin>
                                SSLOptions +StdEnvVars
                </Directory>
        </VirtualHost>
</IfModule>" >/etc/apache2/sites-available/ssl-$1.conf
}
# check apache2 is it installed
if [ -z `command -v apache2` ];then
        echo -e "apache2 not found \n you maybe need to run \"sudo apt get install apache2\""
        exit
        # if apache2 is not installed ,then exit this bash
fi

for lines in `ls $var_web_root`;do
        if [ -d "$var_web_root/$lines" ];then
                echo_default_conf $lines $var_web_root/$lines
                echo_ssl_conf $lines $var_web_root/$lines
        fi
done
