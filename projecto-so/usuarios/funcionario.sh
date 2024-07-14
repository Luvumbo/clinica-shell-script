#!/bin/bash
usuario=$(whoami)

logs="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/logs"

log_info(){
   echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$logs/system.log"
}

log_error(){
   echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "$logs/error.log"
}

raiz="$(dirname "$PWD")"
origem="$raiz/base de dados"

historico="$origem/historico"

if [ ! -d "$historico" ]; then
    mkdir -p "$historico"
fi


# Paciente



consultas_paciente="$origem/consultas_paciente.txt"

if [ ! -f "consultas_paciente" ]; then
    touch "$consultas_paciente"
fi

paciente_exame="$origem/paciente_exame.txt"

if [ ! -f "paciente_exame" ]; then
    touch "$paciente_exame"
fi

#Historico

consultas_paciente_historico="$historico/consultas_paciente_historico.txt"

if [ ! -f "consultas_paciente_historico" ]; then
    touch "$consultas_paciente_historico"
fi



#Medico

consultas_feita="$origem/consultas_feita.txt"

if [ ! -f "consultas_feita" ]; then
    touch "$consultas_feita"
fi

exame_feito="$origem/exame_feito.txt"

if [ ! -f "exame_feito" ]; then
    touch "$exame_feito"
fi

paciente_morto="$origem/paciente_morto.txt"

if [ ! -f "paciente_morto" ]; then
    touch "$paciente_morto"
fi

#Hisorico 

consultas_feita_historico="$historico/consultas_feita_historico.txt"

if [ ! -f "consultas_feita_historico" ]; then
    touch "$consultas_feita_historico"
fi

exame_feito_historico="$historico/exame_feito_historico.txt"

if [ ! -f "exame_feito_historico" ]; then
    touch "$exame_feito_historico"
fi

paciente_morto_historico="$historico/paciente_morto_historico.txt"

if [ ! -f "paciente_morto_historico" ]; then
    touch "$paciente_morto_historico"
fi

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

function verificar_medico {
    local medico_verificar="$1"
    if grep -q "^${medico_verificar}:" /etc/passwd; then
        return 0 
    else
        return 1 
        
    fi
}

function fazerMarcacao {
    clear
    figlet "Marcacoes"
    echo ""
    echo -e "Digite os dados do paciente:"
    echo ""

    while true; do
        read -p "Nome: " nome
        if [[ -z "$nome" ]]; then
            echo "Nome não pode estar vazio. Por favor, digite novamente."
        else
            break
        fi
    done

    while true; do
        read -p "Gênero (M ou F): " genero

        if [[ "$genero" == "M" || "$genero" == "m" ]]; then
            genero="M"
            break
        elif [[ "$gender" == "F" || "$genero" == "f" ]]; then
            genero="F"
            break
        else
            echo "Opção inválida. Escolha M para masculino ou F para feminino."
        fi
    done

    while true; do
        read -p "Data de nascimento (ddmmaaaa): " data_nascimento
        if [[ ! "$data_nascimento" =~ ^([0-9]{2})([0-9]{2})([0-9]{4})$ ]]; then
            echo "Formato inválido. Use o formato ddmmaaaa (8 dígitos)."
        else
            dia="${data_nascimento:0:2}"
            mes="${data_nascimento:2:2}"
            ano="${data_nascimento:4:4}"


            ((dia = 10#$dia))
            ((mes = 10#$mes))
            ((ano = 10#$ano))

            if ((dia < 1 || dia > 31)); then
                echo "Dia inválido. Deve estar entre 01 e 31."
            elif ((mes < 1 || mes > 12)); then
                echo "Mês inválido. Deve estar entre 01 e 12."
            elif ((ano < 1 || ano > 2024)); then
                echo "Ano inválido. Deve estar entre 0001 e 2024."
            else
                data_nascimento_formato="${dia}-${mes}-${ano}"
                echo "$data_nascimento_formato"
                data_nascimento=$data_nascimento_formato
                break
            fi
        fi
    done

    while true; do
        read -p "Telefone: " telefone
        if [[ ! "$telefone" =~ ^[0-9]{9,13}$ ]]; then
            echo "Telefone inválido. Deve conter entre 9 e 13 dígitos numéricos."
        else
            break
        fi
    done

    while true; do
        read -p "Data da consulta (ddmmaaaa): " data_consulta
        if [[ ! "$data_consulta" =~ ^([0-9]{2})([0-9]{2})([0-9]{4})$ ]]; then
            echo "Formato inválido. Use o formato ddmmaaaa (8 dígitos)."
        else
            dia="${data_consulta:0:2}"
            mes="${data_consulta:2:2}"
            ano="${data_consulta:4:4}"


            ((dia = 10#$dia))
            ((mes = 10#$mes))
            ((ano = 10#$ano))

            mes_corrente=$(date +%m)
            ano_corrente=$(date +%Y)

            if ((dia < 1 || dia > 31)); then
                echo "Dia inválido. Deve estar entre 01 e 31."
            elif ((mes < 1 || mes > 12)); then
                echo "Mês inválido. Deve estar entre 01 e 12."
            elif ((ano < 1 || ano > 2024)); then
                echo "Ano inválido. Deve estar entre 0001 e 2024."
            elif ((ano < ano_corrente)); then
                echo "Ano da consulta não pode ser anterior ao ano atual (${ano_corrente})."
            elif ((ano == ano_corrente && mes < mes_corrente)); then
                echo "Mês da consulta não pode ser anterior ao mês atual (${mes_corrente})."
            else
                formato="${dia}-${mes}-${ano}"
                echo "$formato"
                data_consulta=$formato
                break
            fi
        fi
    done
    
	declare -a medicos_disponiveis=()
	while IFS=: read -r usuario _ uid _ _ _ _; do
    if [[ -n "$usuario" && "$uid" -ge 1001 && "$uid" -le 1099 ]]; then
        medicos_disponiveis+=( "$usuario" )
    fi
 done < "/etc/passwd"

    while true; do
    echo -e "Escolha o médico que realizará a consulta:"
    for (( i=0; i<${#medicos_disponiveis[@]}; i++ )); do
        echo "$((i+1)) - ${medicos_disponiveis[$i]}"
    done
    read -p "Opção: " opcao_medico
    if [[ $opcao_medico -ge 1 && $opcao_medico -le ${#medicos_disponiveis[@]} ]]; then
        medico="${medicos_disponiveis[$((opcao_medico-1))]}"
        verificar_medico "$medico"
        if [[ $? -eq 0 ]]; then
            break
        else
            echo "Médico selecionado não encontrado. Escolha um médico válido."
        fi
    else
        echo "Opção inválida. Escolha uma das opções disponíveis."
    fi
done

 while true; do
        echo -e "Área da consulta (Digite o número da opção): "
        echo "1 - Oncologia"
        echo "2 - Cardilogia"
        echo "3 - Nutrologia"
        read area
        if [[ "$area" != "1" && "$area" != "2" && "$area" != "3" ]]; then
            echo "Opção inválida. Escolha uma das opções disponíveis."
        else
            case $area in
            1) area="Oncologia" ;;
            2) area="Cardilogia" ;;
            3) area="Nutrologia" ;;
            esac
            break
        fi
    done

    while true; do
        echo -e "Estado do paciente: "
        echo "1 - Grave"
        echo "2 - Não grave"
        read estado
        if [[ "$estado" != "1" && "$estado" != "2" ]]; then
            echo "Opção inválida. Escolha uma das opções disponíveis."
        else
            case $estado in
            1) estado="Grave" ;;
            2) estado="Não grave" ;;
            esac
            break
        fi
    done

    if [ "$estado" == "Grave" ]; then
        pagamento=false
    else
        pagamentoConsulta
        pagamento=true
    fi

    nota=""

arquivo="$consultas_paciente"
historico="$consultas_paciente_historico"

id=$(wc -l < "$arquivo")
id=$((id + 1))

linha="$id;$nome;$genero;$data_nascimento;$telefone;$data_consulta;$area;$estado;$medico;$pagamento;$nota"

if echo "$linha" >> "$arquivo"; then
    echo ""
    echo "MARCAÇÃO FEITA COM SUCESSO!"
    log_info "O usuário $usuario fez uma marcação de consulta para o paciente $nome"

    # Salvar no histórico
    if echo "$linha" >> "$historico"; then
        echo ""
    else
        echo "Erro ao salvar no histórico."
        log_error "Erro ao salvar marcação de consulta no histórico."
    fi

else
    echo ""
    echo "Erro ao salvar a marcação. Verifique as permissões ou tente novamente."
    log_error "Erro ao fazer marcação de consulta, usuário $usuario"
fi


    echo ""

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./funcionario.sh
            break
        fi
    done
}

function consultarMarcacoes {
    clear
    figlet "Lista de Marcacoes"
    echo ""

    arquivo="$consultas_paciente"

    if [ ! -f "$arquivo" ] || [ ! -s "$arquivo" ]; then
        echo -e "Lista de marcacoes vazia."
        echo ""

        while true; do
            read -p "Digite 1 para voltar: " caso

            if [ "$caso" == "1" ]; then
                ./funcionario.sh
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

    log_info "O usuário $usuario acessou a lista de marcacoes para consultas"

    echo ""

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./funcionario.sh
            break
        fi
    done
}

function marcarExame {
    clear
    figlet "MARCAR EXAME"

    echo ""
    echo -e "Digite os dados do paciente:"
    echo ""
    echo -e "Id da consulta: "
    read procurar_id

    arquivo="$consultas_feita"
    resultado=false

    while IFS=';' read -r id nome genero data_nascimento telefone data_consulta area estado medico pagamento nota; do
        if [ "$id" == "$procurar_id" ]; then
            echo "Id: $id"
            echo "Nome: $nome"
            echo "Gênero: $genero"
            echo "Data de Nascimento: $data_nascimento"
            echo "Telefone: $telefone"
            echo "Dia da Consulta: $data_consulta"
            echo "Área de consulta: $area"
            echo "Estado do paciente: $estado"
            echo "Médico: $medico"
            echo "Pago: $pagamento"
            echo "Nota: $nota"
            echo "-------------------"
            resultado=true

            if [ "$pagamento" == "false" ]; then
                # Marcar o exame
                if echo "$id;$nome;$genero;$data_nascimento;$telefone;$data_consulta;$area;$estado;$medico;$pagamento;$nota" >> "$paciente_exame"; then
                    echo "Marcação de Exame feita com Sucesso"
                    log_info "O $medico fez a Marcação do Exame com Sucesso para o $nome"
                else
                    echo "Erro ao fazer marcação de exame para o paciente $nome"
                    log_error "$medico Erro ao fazer marcação de exame para o paciente $nome"
                fi
            else
                pagamentoExame
                pagamento="true"
            fi

            break
        fi
    done < "$arquivo"

    if ! $resultado; then
        echo "ID do paciente não encontrado."
    fi

    local caso
    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./funcionario.sh
            return 
        else
            echo "Opção inválida. Por favor, selecione 1."
        fi
    done
}



function consultarBoletimObito {
    clear
    figlet "Boletim de Obito"
    echo ""

    arquivo="$paciente_morto"

    if [ ! -f "$arquivo" ] || [ ! -s "$arquivo" ]; then
        echo -e "Boletim de Obito vazio"
        echo ""

        while true; do
            read -p "Digite 1 para voltar: " caso

            if [ "$caso" == "1" ]; then
                ./funcionario.sh
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
                echo "Área de consulta: $area"
                echo "Estado do paciente: $estado"
                echo "Médico: $medico"
                echo "Pago: $pagamento"
                echo "Data da Morte: $data_morte"
                echo "-------------------"
                echo "CAUSA DA MORTE"
                echo "$nota"
                echo "-------------------"
        fi
    done <"$arquivo"

    log_info "O usuário $usuario acessou ao boletim de obito"
    echo ""

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./funcionario.sh
            break
        fi
    done
}

function consultarPagamentoPendente {
    clear
    figlet "Pagamentos Pendentes"
    echo ""

    arquivo1="$exame_feito"
    arquivo2="$consultas_feita"

    if [ ! -f "$arquivo1" ] || [ ! -f "$arquivo2" ]; then
        echo -e "Pelo menos um dos arquivos de pagamentos pendentes não existe."
        echo ""

        while true; do
            read -p "Digite 1 para voltar: " caso

            if [ "$caso" == "1" ]; then
                ./funcionario.sh
                return
            fi
        done
    fi
    echo ""

    function processarArquivo {
        local arquivo="$1"
        while IFS=';' read -r id nome genero data_nascimento telefone data_consulta area estado medico pagamento nota; do
            if [[ -n "${id// /}" ]] && [ "$pagamento" == "false" ]; then
                echo "Id: $id"
                echo "Nome: $nome"
                echo "Gênero: $genero"
                echo "Data de Nascimento: $data_nascimento"
                echo "Telefone: $telefone"
                echo "Dia da Consulta: $data_consulta"
                echo "Área de consulta: $area"
                echo "Estado do paciente: $estado"
                echo "Médico: $medico"
                echo "Pago: $pagamento"
                echo "$nota"
                echo "-------------------"
            fi
        done < "$arquivo"
    }

    if [ -f "$arquivo1" ]; then
        processarArquivo "$arquivo1"
    fi

    if [ -f "$arquivo2" ]; then
        processarArquivo "$arquivo2"
    fi

    log_info "O usuário $usuario acessou a lista de pagamentos pendentes"

    echo ""

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./funcionario.sh
            return
        fi
    done
}


function pagamentoExame {
    echo ""
    echo "PAGAMENTO DO EXAME"
    echo "----------------------"
    echo ""
    echo "Selecione a forma de pagamento:"
    echo "
1 - Dinheiro
2 - Transferência
    "

    while true; do
        read -p "Seleciona uma das opções: " option

        case $option in
        1)
            echo ""
            echo "Pagamento em Dinheiro selecionado."
            echo ""
            echo "Valor a pagar: 20.000 kzs"
            echo ""
            echo "1. Confirmar"
            echo ""

            read confirm
            if [ "$confirm" == "1" ]; then
                break  
            else
                echo "Opção inválida. Por favor, selecione 1 para confirmar."
            fi
            ;;
        2)
            echo ""
            echo "Pagamento com Transferência selecionado."
            echo ""
            echo "Valor a pagar: 20.000 kzs"
            echo ""
            echo "1. Confirmar recepção do comprovativo"
            echo ""

            read confirm
            if [ "$confirm" == "1" ]; then
                break  
            else
                echo "Opção inválida. Por favor, selecione 1 para confirmar."
            fi
            ;;
        *)
            echo ""
            echo "Opção inválida. Por favor, selecione 1 ou 2."
            echo ""
            ;;
        esac
    done
}


function pagamentoConsulta {
    echo ""
    echo "PAGAMENTO DA CONSULTA"
    echo "----------------------"
    echo ""
    echo "Seleciona a forma de pagamento:"
    echo "
1 - Dinheiro
2 - Transferência
    "

    while true; do
        read -p "Seleciona uma das opcoes: " option

        case $option in
        1)
            echo ""
            echo "Pagamento em Dinheiro selecionado."
            echo ""
            echo "Valor a pagar: 10.000 kzs"
            echo ""
            echo -e "1. Confirmar"
            echo ""

            while true; do
                read confirm

                if [ "$confirm" == "1" ]; then
                    break
                fi
            done
            break
            ;;
        2)
            echo ""
            echo "Pagamento com transferência selecionado"
            echo ""
            echo "Valor a pagar: 20.000 kzs"
            echo ""
            echo "Referência: AO06.00.0000.0000.0000.0000.0"
            echo ""
            echo -e "1. Confirmar recepção do comprovativo"
            echo ""

            while true; do
                read confirm

                if [ "$confirm" == "1" ]; then
                    break
                fi
            done
            break
            ;;
        *)
            echo ""
            echo "Opção inválida. Por favor, selecione 1 ou 2."
            echo ""
            ;;
        esac

    done
}

clear
figlet "ATENDENTE"
echo ""
echo "Bem vindo/a $usuario"

echo " 
--------------------------------
| 1. Fazer Marcacao            |
| 2. Consultar Marcacoes       |
| 3. Marcar Exame  	       |
| 4. Boletim de Obito          |
| 5. Pagamentos Pendentes      | 
| 6. Sair                      |
--------------------------------
"
read opcao

echo ""

case $opcao in

1)
    fazerMarcacao 
    ;;
    
    
2)

     consultarMarcacoes
     ;;

3)  marcarExame
    ;;

4)  consultarBoletimObito
    ;;

5)  consultarPagamentoPendente
     ;;
    
6) 
    cd ../usuarios
        chmod a+x login.sh
        ./login.sh
        ;;
*)

    echo "Opcao nao disponivel, escolha um dos numeros apresentados!"
    echo ""
    ;;
esac












