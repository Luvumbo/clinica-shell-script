#!/bin/bash
usuario=$(whoami)

logs="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/logs"

log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $1" >>"$logs/system.log"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR] $1" >>"$logs/error.log"
}

function adicionarFiliias {
	clear

next_uid=1200

while true; do
    echo "Insira o nome da Filial (ou 'q' para sair):"
    read user

    if [[ "$user" == "q" ]]; then
        break
    fi

    echo "Criando uma Filial com nome '$user' "
    log_info "O usuário $usuario adicionou a Filial $opcao"

    sudo addgroup --gid $next_uid "$user"

    if [ $? -eq 0 ]; then
        echo "Filial '$user' adicionada com UID $next_uid."
    else
        echo "Erro ao adicionar filial '$user'."
          log_info "O usuário $usuario nao conseguiu adicionar a  Filial $opcao"
    fi

    ((next_uid++))
done

    
    
    echo ""
    echo "1. Voltar"
    echo "2. Sair"
    
    read -p "Escolha uma opção: " caso

    if [ "$caso" == "1" ]; then
        ./filiais.sh
    fi
    			
    if [ "$caso" == "2" ]; then
    	 cd ../usuarios
    	 ./admin.sh
    fi
	
}

function listarFiliais {
clear
 awk -F':' '$3 >= 1200 && $1 != "nogroup" {print $1}' /etc/group
   log_info "O usuário $usuario acessou a lista das filiais"
 
    echo ""
    echo "1. Voltar"
    echo "2. Sair"
    
    read -p "Escolha uma opção: " caso

    if [ "$caso" == "1" ]; then
        ./filiais.sh
    fi
    			
    if [ "$caso" == "2" ]; then
    	 cd ../usuarios
    	 ./admin.sh
    fi
}



clear

figlet "Filiais da Clinica Santa Muxima"

echo "Bem vindo/a $usuario"

echo ""
echo "1. Visualizar Filiais"
echo "2. Adicionar Filiais"
echo "3. Sair"
	
echo "Escolha uma das opcoes: "

echo ""

read option

echo ""

case $option in 
	
	1) 
		 listarFiliais 
		;;
	2) 
		adicionarFiliias
		
		;;

	3) 
		cd ../usuarios
		chmod a+x ./admin.sh
		./admin.sh
		;;
	
	*) 
		echo "Opcao nao disponivel, escolha um dos numeros apresentados!"
		echo ""
		;;	
esac

		
	





 
