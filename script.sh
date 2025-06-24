#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Cria o endpoint de health check
echo "OK" > /var/www/html/index.html

# Cria o endpoint de teste de carga
mkdir -p /var/www/cgi-bin/
cat <<'EOL' > /var/www/cgi-bin/teste
#!/bin/bash
echo "Content-type: text/plain"
echo ""
echo "Requisição recebida com sucesso no host: $(hostname -f)"
sleep 5
EOL

chmod +x /var/www/cgi-bin/teste

# Habilita CGI no Apache
# Verifica se a configuração já não existe para evitar duplicatas
if ! grep -q 'cgi-bin' /etc/httpd/conf/httpd.conf; then
  echo '
  <Directory "/var/www/cgi-bin">
      Options +ExecCGI
      AddHandler cgi-script .cgi .pl .sh .bash .teste
  </Directory>
  ' >> /etc/httpd/conf/httpd.conf
fi

systemctl restart httpd