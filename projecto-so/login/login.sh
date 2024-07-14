#!/bin/bash

logs="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/logs"

log_info(){
   echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$logs/system.log"
}

log_error(){
   echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "$logs/error.log"
}

clear
figlet "LOGIN"
echo ""
read -p "Insira o nome do usuário: " opcao

#!/bin/bash

uid=$(getent passwd "$opcao" 2>/dev/null | cut -d: -f3)

if [ -n "$opcao" ]; then
    if id -u "$opcao" >/dev/null 2>&1; then
        if [ "$uid" -eq 1000 ]; then
            log_info "O usuário $opcao iniciou sessão como administrador"

            su "$opcao" -c 'cd ../usuarios && ./admin.sh'
            
        elif [ "$uid" -ge 1100 ] && [ "$uid" -le 1199 ]; then
            log_info "O usuário $opcao iniciou sessão como paciente"
            
            su "$opcao" -c 'cd ../usuarios && ./funcionario.sh'

            ./funcionario.sh
        elif [ "$uid" -ge 1001 ] && [ "$uid" -le 1099 ]; then
            log_info "O usuário $opcao iniciou sessão como médico"

            su "$opcao" -c 'cd ../usuarios && ./medico.sh'

        else
            echo "Usuário $opcao não possui perfil adequado."
            log_error "O usuário $opcao não possui perfil adequado"
        fi
    else
        echo "Usuário $opcao não existe!"
        log_error "O usuário $opcao não existe"
    fi
else
    echo "Nome de usuário não especificado!"
    log_error "Nome de usuário não especificado"
fi
echo -e "1. Tentar Novamente"
echo -e "2. Sair"

read -p "Escolha uma opção: " caso

if [ "$caso" == "1" ]; then
	cd ../login
    ./login.sh
elif [ "$caso" == "2" ]; then
    exit
fi
