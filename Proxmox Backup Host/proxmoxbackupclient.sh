#!/bin/bash
# Para execução nos clientes UBUNTU/ZORIN exclusivamente com o servidor de backup PBS da PROXMOX, conjuntamente com orientações no final deste arquivo.
# Este script implementa a execução do backup tipo PULL não recomendado como politica de backup via agente nas estações.
# A politica padrao de backup é executado via metodologia PUSH, a partir dos servidores de backup
# Incluir a criação do arquivo de filtro de arquivos /home/.pxarexclude no custom.sh
# proxmox-backup-client version
PKG_VER="1.1.13-2"
nome="bkryza/onedata-1909-bionic"
repo=$(apt-cache policy | grep http | awk '{print $2 $3}' | sort -u | grep "$nome" )
if [ -n "$repo" ] ;
then echo
	echo "Repositorio $nome ja instalado"
else echo
	echo "Repositorio $nome Necessario-> Adicionando..."
	add-apt-repository ppa:bkryza/onedata-1909-bionic -y
fi
# prepare STATION
apt update
apt install -y libfuse3-3 qrencode -y
ln -s /usr/lib/x86_64-linux-gnu/libapt-pkg.so.6.0.0 /usr/lib/x86_64-linux-gnu/libapt-pkg.so.5.0.0
ln -s /usr/lib/x86_64-linux-gnu/libapt-pkg.so.6.0 /usr/lib/x86_64-linux-gnu/libapt-pkg.so.5.0
cd /var/tmp
# download CLIENT
wget -c -t 0 -T 0 http://download.proxmox.com/debian/pbs/dists/buster/pbs-no-subscription/binary-amd64/proxmox-backup-client_${PKG_VER}_amd64.deb
# extract .deb
ar x proxmox-backup-client_${PKG_VER}_amd64.deb
tar -xJf data.tar.xz
# copy files to /usr/local
cp -af usr/bin /usr/local
cp -af usr/share /usr/local
# CRIAR O ARQUIVO /home/.pxarexclude PARA EXCLUIR PASTAS E ARQUIVOS DIVERSOS e MANTER .config e .mozilla
####################################################################### A SEQUENCIA DAS LINHAS ALTERA OS RESULTADOS 
if [ ! -f /home/.pxarexclude ]; then
	echo "lost+found/" >  /home/.pxarexclude
	echo "administrador/" >> /home/.pxarexclude
	echo "**/custom/" >> /home/.pxarexclude
	echo "**/Downloads/" >> /home/.pxarexclude
	echo "**/Modelos/" >> /home/.pxarexclude
	echo "**/PDF/" >> /home/.pxarexclude
	echo "**/Público/" >> /home/.pxarexclude
	echo "**/snap/" >> /home/.pxarexclude
	echo "**/Templates/" >> /home/.pxarexclude
	echo "**/*Diario_Oficial*" >> /home/.pxarexclude
	echo "**/*.desktop" >> /home/.pxarexclude
	echo "**/*HOD*" >> /home/.pxarexclude
	echo "**/.~*.*" >> /home/.pxarexclude
	echo "**/*.old" >> /home/.pxarexclude
	echo "**/*.7[zZ]" >> /home/.pxarexclude
	echo "**/*.[aA][aA]*" >> /home/.pxarexclude
	echo "**/*.[aA][cC]*" >> /home/.pxarexclude
	echo "**/*.[aA][rR][jJ]" >> /home/.pxarexclude
	echo "**/*.[aA][vV]*" >> /home/.pxarexclude
	echo "**/*.[bB][zZ]2" >> /home/.pxarexclude
	echo "**/*.[cC][rR][tT]" >> /home/.pxarexclude
	echo "**/*.[dD][vV][iI]*" >> /home/.pxarexclude
	echo "**/*.[eE][xX][eE]" >> /home/.pxarexclude
	echo "**/*.[fF][lL]?" >> /home/.pxarexclude
	echo "**/*.[gG][zZ]" >> /home/.pxarexclude
	echo "**/*.[iI][sS][oO]" >> /home/.pxarexclude
	echo "**/*.[mM][pP]*" >> /home/.pxarexclude
	echo "**/*.[mM][oO][vV]*" >> /home/.pxarexclude
	echo "**/*.[mM[kK]*" >> /home/.pxarexclude
	echo "**/*.[mM][sS][iI]" >> /home/.pxarexclude
	echo "**/*.[oO][lL][dD]" >> /home/.pxarexclude
	echo "**/*.[rR][mM]*" >> /home/.pxarexclude
	echo "**/*.[rR][aA][rR]" >> /home/.pxarexclude
	echo "**/*.[tT][gG][zZ]" >> /home/.pxarexclude
	echo "**/*.[wW][eE][bB][mM]*" >> /home/.pxarexclude
	echo "**/*.[wW][aA][vV]*" >> /home/.pxarexclude
	echo "**/*.[wW][mM]*" >> /home/.pxarexclude
	echo "**/*.[wW][eE][bB][mM]*" >> /home/.pxarexclude
	echo "**/*.[zZ]" >> /home/.pxarexclude
	echo "**/*.[zZ][iI][pP]" >> /home/.pxarexclude
	echo "**/.[A-Z]*" >> /home/.pxarexclude
	echo "**/.[a-z]*" >> /home/.pxarexclude
	echo "**/.[0-9]*" >> /home/.pxarexclude
	echo "!**/.config/" >> /home/.pxarexclude
	echo "!**/.mozilla/" >> /home/.pxarexclude
fi
#######################################################################
exit

