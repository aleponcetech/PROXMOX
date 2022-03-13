#!/bin/bash
# cuidado ao executar em shells diferentes (ubuntu x zorin IF [ ] OU IF [[]] )
# ESTE SCRIPT EH ENVIADO POR SCP NA EXECUÇÃO DO SCRIPT xbackupremoto.sh PARA SER EXECUTADO VIA SSH NA ESTAÇÃO
# variaveis para a execução do comando proxmox-backup-client backup
export PBS_PASSWORD='senha USERPBS'
export PBS_REPOSITORY='USERPBS@pbs@IPservidorPBS:BECAPE'
export PBS_FINGERPRINT='77:87:22:aA:bb:77:dD:88:66:66:44:11:00:88:aA:75:11:aa:11:cc:11:11:55:ff:dd:22:22:aa:88:bb:44:66'
# (re)INSTALAÇÃO do client de backup, SFC
if [ ! -f /usr/local/bin/proxmox-backup-client ]; then
	echo $PBS_PASSWORD | sudo -S sh +x /home/administrador/proxmoxbackupclient.sh
fi
# comando que efetivamente envia o backup para o PBS
proxmox-backup-client backup administrador.pxar:/home --backup-id `ip addr show |grep "inet " |grep -v 127.0.0. |head -1|cut -d" " -f6|cut -d/ -f1`
# remove este script da estação por segurança
rm -f /home/administrador/backup.sh
