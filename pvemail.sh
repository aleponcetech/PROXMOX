#!/bin/bash

# Variaveis
SMTP=mail.edalbem.com.br
MAIL=envioproxmox@edalbem.com.br
SENHA=envioproxmox@2021

# Instala os pacotes
apt update
apt-get install libsasl2-modules fail2ban sudo mailutils -y

cp /etc/postfix/main.cf /etc/postfix/main.cf.bkp

echo "
myhostname=`hostname -f`

# Informe o endereço SMTP e a porta
relayhost=[`echo $SMTP`]:587

# O servidor smtp utiliza TLS
smtp_use_tls=yes

# usar sasl ao autenticar em servidores SMTP estrangeiros
smtp_sasl_auth_enable=yes

# caminho para o arquivo de mapeamento de senha
smtp_sasl_password_maps=hash:/etc/postfix/sasl/passwd

# lista de CAs para confiar na verificação
smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt

# elimina as opções de segurança padrão do gmail
smtp_sasl_security_options=noanonymous

# Desabilita o protocolo IPV6
inet_protocols = ipv4

# Debug caso precise
#debug_peer_list=smtp.gmail.com
#debug_peer_level=3
" > /etc/postfix/main.cf

# Configura o email e senha de envio
echo "[`echo $SMTP`]:587 `echo $MAIL`:`echo $SENHA`" > /etc/postfix/sasl/passwd
chown -R postfix /etc/postfix/sasl
postmap /etc/postfix/sasl/passwd

# Reinicia o serviço e envia um email de testes
/etc/init.d/postfix reload

echo `hostname -f` | mail -s teste $MAIL

##########################################

# Configura o fail2ban pra bloquear o acesso ao proxmox ao acessar N Vezes senha inválida
# wget https://raw.githubusercontent.com/Tontonjo/proxmox_toolbox/main/pve/filter.d/proxmox-virtual-environement.conf -O  /etc/fail2ban/filter.d/proxmox-virtual-environement.conf
# wget https://raw.githubusercontent.com/Tontonjo/proxmox_toolbox/main/pve/jail.d/proxmox-virtual-environement.conf -O /etc/fail2ban/jail.d/proxmox-virtual-environement.conf

# systemctl restart fail2ban.service


##########################################

# Ativa o teste de SMART de disco as 5 da manhã
cp /etc/smartd.conf /etc/smartd.conf.BCK
echo "DEVICESCAN -d auto -n never -a -s (S/../../7/05|L/../01/./05) -m root -M exec /usr/share/smartmontools/smartd-runner" > "/etc/smartd.conf"

##########################################

# Configura o PVE a só usar swap com 90% do uso de RAM

echo "vm.swappiness=30" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
