#!
# ESTE SCRIPT( mais 3 requisitos) FOI DESENVOLVIDO PARA SER ACIONADO PELO CRONTAB DO SERVIDOR PROXMOX-BACKUP-SERVER
# cuidado ao executar em shells diferentes ---->>    (ubuntu x zorin há diferenças entre   if [[    ]] ou if [  ]  )
# Este script executa o backup remoto nas estações a partir das preconfigurações (geração das chaves no PBS e envio da chave publica para todos os IPs);
# Não executa o backup dos desktops windows, mas pode ser anexado facilmente
#################################################################################################################################################
SAIR="N"
# Verifica se a lista de IP das estacoes a ser processada esta presente
if [ ! -f xbackuplist.ip ]; then
	SAIR="S"
fi
# Verifica a existencia do script que realiza o backup nas estacoes
if [ ! -f backup.sh ]; then
	SAIR="S"
fi
# Registra o Log da execução de cada estação
DTL="/var/log/proxmox-backup/"$(date +"%Y%m%d")"remotos.log"
if [ ! -f $DTL ]; then
	touch $DTL
fi
# Bloqueio contra execução recursiva e reset do bloqueio, SFC
LOCKBKP=$DTL".lock"
if [ ! -f $LOCKBKP ]; then
	touch $LOCKBKP
else
	TEMPO=$(date -d "now - $( stat -c "%Y" $LOCKBKP ) seconds" +%s)
	# testa se o inicio do ultimo backup foi a mais de 8h e remove o bloqueio
	if  [ $TEMPO -gt "28800" ]; then
		SAIR="S"
	fi
fi
# Saida ou desbloqueio
if [ SAIR = "S" ]; then
	if [ -f $LOCKBKP ]; then
		rm -f $LOCKBKP
	fi
	exit
fi
# processa o arquivo xbackuplist.ip que contem um IP por linha dos desktops linux
while read output junk <&3
do
    case $output in
                # ignora linhas iniciadas com #
	"#"*|"")
	;;
	*)
		# verifica se o IP corrente esta contido no arquivo de log evitando a duplicacao de backup do dia
		grep -wq $output $DTL
		if [ ! $? -eq 0 ]; then
			# testa a disponibilidade do host
			ping -c 1 "$output" >> /dev/null
			if [ $? -eq 0 ]; then
				# registra o backup no log de controle
				echo $output >> $DTL
				# copia o script a ser executado em todos os desktops linux
				scp backup.sh proxmoxbackupclient.sh secinfor@$output:/home/secinfor
				# abre um tunel para o host e envia o script para executar o backup
				ssh secinfor@$output "sh +x /home/secinfor/backup.sh"
			fi
		fi

	;;
	esac
done 3< xbackuplist.ip
					rm -f $LOCKBKP
					exit



