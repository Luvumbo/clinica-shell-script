#!/bin/bash

logs="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/logs"

log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $1" >>"$logs/system.log"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR] $1" >>"$logs/error.log"
}

raiz="$(dirname "$PWD")"
origem="$raiz/base de dados"
historico="$origem/historico"

consultas_paciente_historico="$historico/consultas_paciente_historico.txt"
consultas_feita_historico="$historico/consultas_feita_historico.txt"
exame_feito_historico="$historico/exame_feito_historico.txt"
paciente_morto_historico="$historico/paciente_morto_historico.txt"



function retorno {


    echo "1. Voltar"
    echo "2. Sair"
    
    read -p "Escolha uma opção: " opcao

    case $opcao in
    
    1)
        clear
        cd ../usuarios
        ./admin.sh
        ;;
    2)
        cd ..
        cd login
        ./login.sh
        ;;
    *)
        echo "Opção inválida. Por favor, escolha novamente."
        retorno
        ;;
    esac


}


function arquivo {

	

raiz="$(dirname "$PWD")"
origem="$raiz/base de dados"
origem2="$raiz/logs"
destino="/mnt/Copia de Seguranca"

log_info="$raiz/logs/backup_info.log"
log_error="$raiz/logs/backup_error.log"

if [ ! -d "$destino" ]; then
    mkdir -p "$destino"
    if [ $? -ne 0 ]; then
        echo "Erro ao criar o diretório de destino: $destino."
        log_error "$usuario: Erro ao criar o diretório de destino: $destino."
        exit 1
    fi
fi


mkdir -p "$(dirname "$log_info")"
mkdir -p "$(dirname "$log_error")"

registrar_log() {

    local tipo="$1"  # Tipo de log: "info" ou "error"
    local mensagem="$2" 

    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$tipo] $mensagem" >> "$log_info"
    if [ "$tipo" = "error" ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$tipo] $mensagem" >> "$log_error"
    fi
}

registrar_log "info" "Iniciando cópia de $origem para $destino"


sudo cp -r "$origem"/* "$destino" 2>> "$log_error"
sudo cp -r "$origem2"/* "$destino" 2>> "$log_error"

if [ $? -eq 0 ]; then
    registrar_log "info" "Copia de Seguranca Efetuado com Sucesso."
    echo "Copia de Seguranca Efetuado com Sucesso."
     log_info "O usuário $usuario efectou copia de seguranca"
     retorno
else
    registrar_log "error" "Erro ao copiar os arquivos."
    echo "Erro ao copiar os arquivos."
      log_error "O usuário $usuario nao conseguiu efectuar a copia de seguranca"
      retorno
fi

registrar_log "info" "Fim do processo de  Copia de Seguranca ."
}

function copia {

	clear
	  figlet "Copia de Seguranca"
	echo "1. Historico de Copia de Seguranca "
	echo "2. Fazer Copia de Seguranca "
	echo "3. Voltar"
        echo "4. Sair"
	read -p "Escolha uma opção: " opcao
	
	
	

    case $opcao in
    1)
        clear
        log_info "O usuário $usuario acessou ao historico de copia de seguramca"
        cd ..
        cd logs
        cat backup_error.log
        cat backup_info.log
        retorno
        ;;
    2)
      	arquivo
        
        ;;
    3)
        clear
        ./admin.sh
        ;;
    4)
        cd ..
        cd login
        ./login.sh
        ;;
    *)
        echo "Opção inválida. Por favor, escolha novamente."
        retorno
        ;;
    esac

}

function logs {
    clear
    figlet "Logs"
    echo "1. Ver Informacoes de Logs de Erro"
    echo "2. Ver Informacoes de Logs de Informacao"
    echo "3. Voltar"
    echo "4. Sair"

    read -p "Escolha uma opção: " opcao

    case $opcao in
    1)
        clear
        cd ../logs
         log_info "O usuário $usuario acessou as informacoes de logs de erros"
         arquivo="error.log"
        if [ -s "$arquivo" ]; then
         figlet "Logs de Erro"
         echo ""
	 cat error.log
	else
	figlet "Logs de Erro"
	echo ""
	    echo "Nao existem registros de logs de erro"
	fi
        cd ../usuarios
        while true; do
            read -p "Digite 1 para voltar: " caso

            if [ "$caso" == "1" ]; then
                ./admin.sh
                break
            fi
        done
        ;;
    2)
        clear
        cd ../logs
        log_info "O usuário $usuario acessou as informacoes de logs de informacaoS"
        arquivo="system.log"
        if [ -s "$arquivo" ]; then
        figlet "Logs de Informacao"
        echo ""
	 cat system.log
	else
	figlet "Logs de Informacao"
        echo ""
	    echo "Nao existem registros de logs de informacao"
	fi
        cd ../usuarios
        while true; do
            read -p "Digite 1 para voltar: " caso

            if [ "$caso" == "1" ]; then
                ./admin.sh
                break
            fi
        done
        ;;
    3)
        clear
        ./admin.sh
        ;;
    4)
        cd ..
        cd login
        ./login.sh
        ;;
    *)
        echo "Opção inválida. Por favor, escolha novamente."
        retorno
        ;;
    esac
}

function limpeza {
    clear
    figlet "Limpeza do Sistema"
    log_info "O usuário $usuario fez limpeza no sistema"

    sudo -S apt-get autoremove
    sudo -S apt-get autoclean
    sudo -S  apt-get clean

    echo ""
    echo "1. Voltar"
    echo "2. Sair"

    read -p "Escolha uma opção: " caso

    if [ "$caso" == "1" ]; then
        ./admin.sh
    fi

    if [ "$caso" == "2" ]; then
        cd ..
        cd login
        ./login.sh
    fi

}

function cadastrarMedico {
    clear
    figlet "Cadastrar Medicos"
echo "Escolha a qual filial da Clinica Santa Muxima deseja adicionar o Médico:"
echo "1. Clinica Santa Muxima - Talatona"
echo "2. Clinica Santa Muxima - Cazenga"
read -p "Escolha uma opção (1-2): " opcao


case $opcao in
    1)
        grupo="talatona"
        ;;
    2)
        grupo="cazenga"
        ;;
    *)
        echo "Opção inválida, Tente novamente"
        exit 1
        ;;
esac

echo "Insira o nome de usuário do Médico:"
read user

if id "$user" &>/dev/null; then
    echo "Usuário $user já existe."
    log_error "$usuario: Usuário $user já existe"
else
    sudo -S  adduser $user
    sudo  -S usermod -aG $grupo $user
   

    if [ $? -eq 0 ]; then
        echo "Usuário $user foi adicionado com sucesso a Clinica Santa Muxima $grupo."
        log_info "O usuário $usuario adicionou o Medico $user na Filial $grupo"
    else
        echo "Falha ao adicionar o usuário $user na Clinica Santa Muxima $grupo."
        log_error "O usuário $usuario nao conseguiu adicionar o Medico $user na Filial $grupo"
        exit 1
    fi
fi



    retorno 
}

function visualizarMedico {
    clear
    figlet "Lista de Medicos"
    log_info "O usuário $usuario acessou a lista dos Medicos"

    result=$(awk -F':' '$3 >= 1001 && $3 <= 1099 && $1 != "nobody" {print $5}' /etc/passwd | cut -d',' -f1)


	if [ -z "$result" ]; then
	    echo "Nenhum Medico Encontrado."
	else
    	    echo "$result"
	fi


    echo ""
    retorno
}
function apagarMedico {
    clear
    figlet "Apagar Medico"

    echo "Qual Medico pretende deletar?"
    read opcao

    if getent passwd "$opcao" >/dev/null; then
        sudo -S deluser "$opcao"
         log_info "O usuário $usuario apagou o Medico $opcao"
    else
        echo "Usuário $opcao não existe!"
         log_error "O usuário $usuario nao conseguiu apagou o Medico $opcao"
    fi

    echo ""
    echo "1. Voltar"
    echo "2. Sair"
    echo "3. Continuar"

    read -p "Escolha uma opção: " caso

    if [ "$caso" == "1" ]; then
        ./admin.sh
    fi

    if [ "$caso" == "2" ]; then
        exit
    fi

    if [ "$caso" == "3" ]; then
      apagarMedico
    fi
}


function adicionarFuncionario {
   clear
    figlet "Cadastrar Funcionarios"
echo "Escolha a qual filial da Clinica Santa Muxima deseja adicionar o Funcionario:"
echo "1. Clinica Santa Muxima - Talatona"
echo "2. Clinica Santa Muxima - Cazenga"
read opcao
case $opcao in
    1)
        grupo="talatona"
        ;;
    2)
        grupo="cazenga"
        ;;
    *)
        echo "Opção inválida, Tente novamente"
        exit 1
        ;;
esac

next_uid=1100

while id "$next_uid" &>/dev/null; do
    ((next_uid++))
done

while true; do
    echo "Insira o nome de usuário do Funcionário (ou 'q' para sair):"
    read user

    if [[ "$user" == "q" ]]; then
        break
    fi

    if id "$user" &>/dev/null; then
        echo "Usuário $user já existe."
        log_error "$usuario: Usuário $user já existe."
    else
        sudo -S  adduser --uid $next_uid "$user"
        sudo -S usermod -aG $grupo $user
	
        if [ $? -eq 0 ]; then
            echo "Usuário $user foi adicionado com sucesso à Clínica Santa Muxima $grupo."
            log_info "Usuário $user foi adicionado com sucesso à Clínica Santa Muxima $grupo."
            ((next_uid++))
        else
            echo "Falha ao adicionar o usuário $user à Clínica Santa Muxima $grupo."
            log_error "Falha ao adicionar o usuário $user à Clínica Santa Muxima $grupo."
            exit 1
        fi
    fi
done

   retorno

}


function listarFuncionarios {
    clear
    figlet "Lista de Funcionarios"
    echo ""
    log_info "O usuário $usuario acessou a lista de Funcionarios"
    result=$(awk -F':' '$3 >= 1100 && $3 <= 1199 && $1 != "nobody" {print $5}' /etc/passwd | cut -d',' -f1)
     echo ""
	if [ -z "$result" ]; then
    	echo "Nenhum Funcionario encontrado."
	  else
    	echo "$result"
	fi
 echo ""
   retorno
}


function apagarFuncionario {
clear
figlet "Apagar Funcionario"
echo "Qual Funcionario pretende deletar?"
    read opcao

if getent passwd "$opcao" >/dev/null; then
        sudo -S  deluser "$opcao"
        log_info "O usuario $usuario apagou o usuario $opcao "
    else
        echo "Usuário $opcao não existe!"
        log_error "$usuario: Usuário $opcao não existe!"
    fi

    echo ""
    echo "1. Voltar"
    echo "2. Sair"
    echo "3. Continuar"

    read -p "Escolha uma opção: " caso

    if [ "$caso" == "1" ]; then
        ./admin.sh
    fi

    if [ "$caso" == "2" ]; then
        exit
    fi

    if [ "$caso" == "3" ]; then
     apagarFuncionario 
    fi

}

function mortos {
    clear
    log_info "$usuario acessou a limpeza dos mortos no Sistema"
    figlet "LIMPEZA DE MORTOS NO SISTEMA"
    echo ""
    raiz="$(dirname "$PWD")"
    arquivo="$raiz/base de dados/paciente_morto.txt"
    tempfile=$(mktemp)

    if [ ! -f "$arquivo" ]; then
        echo "Erro: o arquivo $arquivo não existe."
        log_error "Erro: o arquivo $arquivo não existe"
        exit 1
    fi

    agora=$(date +%s)
    limite=$(date -d "1 minute ago" +%s)  
    linhas_removidas=0

    while IFS=';' read -r id nome genero data_nascimento telefone data_consulta area estado medico pagamento nota data_morte; do
        if [ -n "$id" ]; then
            timestamp_morte=$(date -d "$data_morte" "+%s")
            if [ "$timestamp_morte" -lt "$limite" ]; then
                echo "Linha removida: $id;$nome;$genero;$data_nascimento;$telefone;$data_consulta;$area;$estado;$medico;$pagamento;$nota;$data_morte"
                ((linhas_removidas++))
            else
                echo "$id;$nome;$genero;$data_nascimento;$telefone;$data_consulta;$area;$estado;$medico;$pagamento;$nota;$data_morte" >> "$tempfile"
            fi
        fi

    done < "$arquivo"

    mv "$tempfile" "$arquivo"

    echo "Processamento concluído. $linhas_removidas linhas removidas."
    log_info "$usuario: Processamento concluído. $linhas_removidas linhas removidas."

    retorno
}


function historico {
clear
figlet "HISTORICO"
log_info "$usuario acessou a lista dos historicos"

echo "1. Marcacoes"
echo "2. Consultas"
echo "3. Exames"
echo "4. Boletim de Obito"
echo "5. Voltar"
echo "6. Sair"

read opcao

echo ""

case $opcao in

1)
    historicoMarcacoes 
    ;;
2)
    historicoConsultas
    ;;
3)
    historicoExames
    ;;
4)
    historicoBoletimObito
    ;;
5)
    clear
        ./admin.sh
    ;;
6)
   cd ../usuarios
   ./login.sh
    ;;
*)
    echo "Opcao nao disponivel, escolha um dos numeros apresentados!"
    echo ""
    ;;
esac

}

function historicoMarcacoes {

    clear
    figlet "HISTORICO DE MARCACOES"
    echo ""

    arquivo="$consultas_paciente_historico"

    if [ ! -f "$arquivo" ] || [ ! -s "$arquivo" ]; then
        echo -e "Historico de marcacoes vazia."
        echo ""

        while true; do
            read -p "Digite 1 para voltar: " caso

            if [ "$caso" == "1" ]; then
                ./admin.sh
                break
            fi
        done
    fi
    echo ""
    while IFS=';' read -r id nome genero data_nascimento telefone data_consulta area estado medico pagamento nota; do
        if [[ -n "${id// /}" ]]; then
            echo "Id: $id"
            echo "Nome: $nome"
            echo "Gênero: $genero"
            echo "Data de Nascimento: $data_nascimento"
            echo "Telefone: $telefone"
            echo "Dia da Consulta: $data_consulta"
            echo "Area de consulta: $area"
            echo "Estado do paciente: $estado"
            echo "Medico: $medico"
            echo "Pago: $pagamento"
            echo "$nota"
            echo "-------------------"
        fi
    done <"$arquivo"

    log_info "O usuário $usuario acessou  o historico de marcacoes para consultas"

    echo ""

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./admin.sh
            break
        fi
    done

}

function historicoConsultas {

    clear
    figlet "HISTORICO DE CONSULTAS"
    echo ""

    arquivo="$consultas_feita_historico"

    if [ ! -f "$arquivo" ] || [ ! -s "$arquivo" ]; then
        echo -e "Historico de consultas vazia."
        echo ""

        while true; do
            read -p "Digite 1 para voltar: " caso

            if [ "$caso" == "1" ]; then
                ./admin.sh
                break
            fi
        done
    fi
    echo ""
    while IFS=';' read -r id nome genero data_nascimento telefone data_consulta area estado medico pagamento nota; do
        if [[ -n "${id// /}" ]]; then
            echo "Id: $id"
            echo "Nome: $nome"
            echo "Gênero: $genero"
            echo "Data de Nascimento: $data_nascimento"
            echo "Telefone: $telefone"
            echo "Dia da Consulta: $data_consulta"
            echo "Area de consulta: $area"
            echo "Estado do paciente: $estado"
            echo "Medico: $medico"
            echo "Pago: $pagamento"
            echo "$nota"
            echo "-------------------"
        fi
    done <"$arquivo"

    log_info "O usuário $usuario acessou  o historico de consultas"

    echo ""

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./admin.sh
            break
        fi
    done

}

function historicoExames {

    clear
    figlet "HISTORICO DE EXAMES"
    echo ""

    arquivo="$exame_feito_historico"

    if [ ! -f "$arquivo" ] || [ ! -s "$arquivo" ]; then
        echo -e "Historico de exames vazia."
        echo ""

        while true; do
            read -p "Digite 1 para voltar: " caso

            if [ "$caso" == "1" ]; then
                ./admin.sh
                break
            fi
        done
    fi
    echo ""
    while IFS=';' read -r id nome genero data_nascimento telefone data_consulta area estado medico pagamento nota; do
        if [[ -n "${id// /}" ]]; then
            echo "Id: $id"
            echo "Nome: $nome"
            echo "Gênero: $genero"
            echo "Data de Nascimento: $data_nascimento"
            echo "Telefone: $telefone"
            echo "Dia da Consulta: $data_consulta"
            echo "Area de consulta: $area"
            echo "Estado do paciente: $estado"
            echo "Medico: $medico"
            echo "Pago: $pagamento"
            echo "$nota"
            echo "-------------------"
        fi
    done <"$arquivo"

    log_info "O usuário $usuario acessou  o historico de exames"

    echo ""

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./admin.sh
            break
        fi
    done

}

function historicoBoletimObito {

    clear
    figlet "HISTORICO DE BOLETIM DE OBITO"
    echo ""

    arquivo="$paciente_morto_historico"

    if [ ! -f "$arquivo" ] || [ ! -s "$arquivo" ]; then
        echo -e "Historico de boletim de obito vazia."
        echo ""

        while true; do
            read -p "Digite 1 para voltar: " caso

            if [ "$caso" == "1" ]; then
                ./admin.sh
                break
            fi
        done
    fi
    echo ""
    while IFS=';' read -r id nome genero data_nascimento telefone data_consulta area estado medico pagamento nota data_morte; do
        if [[ -n "${id// /}" ]]; then
            echo "Id: $id"
            echo "Nome: $nome"
            echo "Gênero: $genero"
            echo "Data de Nascimento: $data_nascimento"
            echo "Telefone: $telefone"
            echo "Dia da Consulta: $data_consulta"
            echo "Area de consulta: $area"
            echo "Estado do paciente: $estado"
            echo "Medico: $medico"
            echo "Pago: $pagamento"
            echo "Causa da Morte :$nota"
            echo "Data da Morte: $data_morte"
            echo "-------------------"
        fi
    done <"$arquivo"

    log_info "O usuário $usuario acessou  o historico de boletim de obito"

    echo ""

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./admin.sh
            break
        fi
    done

}

clear
figlet "Administrador"

usuario=$(whoami)
echo ""
echo "Bem vindo/a $usuario"

echo " 
--------------------------------
| 1. Cadastrar Medicos         |
| 2. Apagar Medicos            |
| 3. Visualizar Medicos        |
| 4. Cadastrar Funcionarios    |
| 5. Apagar Funcionarios       |
| 6. Visualizar Funcionarios   | 
| 7. Filias                    |
| 8. Limpeza do Sistema        |
| 9. Logs do Sistema           |
| 10.Copia de Seguranca        |
| 11.Mortalidade               |
| 12.Historico                 |
| 13.Terminar Sessao           |
--------------------------------
"
read opcao

echo ""

case $opcao in

1)
    cadastrarMedico 
    ;;
2)
    apagarMedico
    ;;
3)
    visualizarMedico
    ;;
4)
    adicionarFuncionario
    ;;

5)
    apagarFuncionario
    ;;
6)

   listarFuncionarios			
    ;;

7)
    cd ../funcoes
    chmod a+x filiais.sh
    ./filiais.sh
    ;;
8)
    limpeza
    ;;
9)
    logs
    ;;
    
10)

    copia
    ;;
    
11)
    
    mortos
    ;;
12)
    historico
    ;;

13)
    cd ../login
    chmod +x login.sh
    ./login.sh
    ;;
    
*)
    echo "Opcao nao disponivel, escolha um dos numeros apresentados!"
    echo ""
    ;;
esac
