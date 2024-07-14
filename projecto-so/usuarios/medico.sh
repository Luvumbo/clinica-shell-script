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
#Paciente
consultas_paciente="$origem/consultas_paciente.txt"
paciente_exame="$origem/paciente_exame.txt"

#Historico 
consultas_paciente_historico="$historico/consultas_paciente_historico.txt"


#Medico

consultas_feita="$origem/consultas_feita.txt"
exame_feito="$origem/exame_feito.txt"
paciente_morto="$origem/paciente_morto.txt"

#Historico 

consultas_feita_historico="$historico/consultas_feita_historico.txt"
exame_feito_historico="$historico/exame_feito_historico.txt"
paciente_morto_historico="$historico/paciente_morto_historico.txt"



function minhasConsulta {
    clear
    figlet "Minhas Consultas"
    echo ""
            
    log_info "O doctor $usuario acessou a lista dos consultas"

    arquivo="$consultas_paciente"

    if [ ! -f "$arquivo" ] || [ ! -s "$arquivo" ]; then
    echo -e "Lista de consultas vazia."
    echo ""
    echo -e "1. Voltar"
    echo ""

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./medico.sh
            break
        fi
    done
else
    echo ""
    
    consulta=0
    while IFS=';' read -r id nome genero data_nascimento telefone data_consulta area estado medico pagamento nota; do

        if [[ -n "${id// /}" ]]; then
         
            if [ "$medico" == "$usuario" ]; then
                consulta=1 
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
                echo "-------------------"
            fi
        fi
    done <"$arquivo"
    if [ $consulta -eq 0 ]; then
        echo "Não há consultas para exibir."
    fi
fi

    echo ""
    echo -e "1. Voltar"
    echo ""

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./medico.sh
            break
        fi
    done
}


function realizarConsulta {
    clear
    figlet "Realizar Consultas"
    echo ""
    echo -e "Digite os dados do paciente:"
    echo ""

    log_info "O doctor $usuario acessou a sessão de realização de consulta"

    while true; do
        echo -e "Id da consulta: "
        read procurar_id

        echo -e "Nota do paciente: "
        read nota

        arquivo="$consultas_paciente"
        resultado=false
        linha_encontrada=""

        # Ler o arquivo de consultas_paciente
        while IFS=';' read -r id nome genero data_nascimento telefone data_consulta area estado medico pagamento nota_antiga; do
            if [ "$id" == "$procurar_id" ]; then
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
                echo "-------------------"
                resultado=true
                linha_encontrada="$id;$nome;$genero;$data_nascimento;$telefone;$data_consulta;$area;$estado;$medico;$pagamento;$nota"
                break
            fi
        done < "$arquivo"

        if [ "$resultado" = true ]; then
        
        if grep -q "^$procurar_id;" "$consultas_feita"; then
        echo "Consulta com ID $procurar_id já foi registrada."
        else
        
        echo "$linha_encontrada" >> "$consultas_feita"
        echo "Consulta realizada e registrada com sucesso."
        log_info "O médico $medico realizou a consulta para o paciente $nome"

        
        if echo "$linha_encontrada" >> "$consultas_feita_historico"; then
            echo ""
        else
            echo "Erro ao salvar no histórico."
            log_error "Erro ao salvar consulta realizada no histórico."
        fi

       
        sed -i "/^$procurar_id;/d" "$consultas_paciente"
    fi

            echo ""
            while true; do
                read -p "Digite 1 para voltar: " caso
                if [ "$caso" == "1" ]; then
                    ./medico.sh
                    exit
                fi
            done
        else
            echo "---------------------------"
            echo ""
            echo -e "ID do usuário não encontrado."
            while true; do
                echo ""
                echo "Escolha uma opção:"
                echo "1. Tentar novamente"
                echo "2. Voltar"
                read caso
                clear

                if [ "$caso" == "1" ]; then
                    break
                elif [ "$caso" == "2" ]; then
                    ./medico.sh
                    exit
                else
                    echo "Opção inválida, tente novamente."
                fi
            done
            clear
        fi
    done

    log_info "O doctor $usuario realizou uma consulta"
}

function resultadoConsulta {
    clear
    figlet "Resultados de Consultas"
    echo ""
    echo -e "Digite os dados do paciente:"
    echo ""
    echo -e "Id da consulta: "
    read procurar_id

    log_info "O doctor $usuario acessou a lista dos resultados das consultas"

    arquivo="$consultas_feita"
    resultado=false
    if [ -s "$arquivo" ]; then
         while IFS=';' read -r id nome genero data_nascimento telefone data_consulta area estado medico pagamento nota; do
            if [ "$id" == "$procurar_id" ]; then
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
                 echo "-------------------"
                echo "$nota"
                echo "-------------------"
                resultado=true
            fi
        done <"$arquivo"

        if ! $resultado; then
            echo -e "Nenhuma resultado da consulta encontrada para o ID informado."
        fi
    else
        echo -e "Nenhum rresultado da consulta encontrada no arquivo."
    fi

    echo ""
    echo -e "1. Voltar"

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./medico.sh
            break
        else
            echo "Opção inválida, tente novamente."
        fi
    done

}

function meusExames {
    clear
    figlet "Meus Exames"
    echo ""
            
    log_info "O doctor $usuario acessou a lista dos exames"

    arquivo="$paciente_exame"

    if [ ! -f "$arquivo" ] || [ ! -s "$arquivo" ]; then
    echo -e "Lista de exames vazia."
    echo ""
    echo -e "1. Voltar"
    echo ""

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./medico.sh
            break
        fi
    done
else
    echo ""
    
    consulta=0
    while IFS=';' read -r id nome genero data_nascimento telefone data_consulta area estado medico pagamento nota; do

        if [[ -n "${id// /}" ]]; then
         
            if [ "$medico" == "$usuario" ]; then
                consulta=1 
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
                echo "-------------------"
            fi
        fi
    done <"$arquivo"
    if [ $consulta -eq 0 ]; then
        echo "Não há exames para exibir."
    fi
fi

    echo ""
    echo -e "1. Voltar"
    echo ""

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./medico.sh
            break
        fi
    done
}


function realizarExame {
    clear
    figlet "Realizar Exames"
    echo ""
    echo -e "Digite os dados do paciente:"
    echo ""

    log_info "O doctor $usuario acessou a sessão de realização de exames"

    while true; do
        echo -e "Id da consulta: "
        read procurar_id

        echo -e "Nota do paciente: "
        read nota

        arquivo="$paciente_exame"
        resultado=false
        linha_encontrada=""

        
        while IFS=';' read -r id nome genero data_nascimento telefone data_consulta area estado medico pagamento nota_antiga; do
            if [ "$id" == "$procurar_id" ]; then
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
                echo "-------------------"
                resultado=true
                linha_encontrada="$id;$nome;$genero;$data_nascimento;$telefone;$data_consulta;$area;$estado;$medico;$pagamento;$nota"
                break
            fi
        done < "$arquivo"

        if [ "$resultado" = true ]; then
          
            if grep -q "^$procurar_id;" "$exame_feito"; then
                echo "Exame com ID $procurar_id já foi registrado."
            else
                
                echo "$linha_encontrada" >> "$exame_feito"
                echo "Exame realizado e registrado com sucesso."
                log_info "O médico $medico realizou o exame para o paciente $nome"

                
                if echo "$linha_encontrada" >> "$exame_feito_historico"; then
                    echo "Dados também salvos no histórico."
                else
                    echo "Erro ao salvar no histórico."
                    log_error "Erro ao salvar exame realizado no histórico."
                fi

                sed -i "/^$procurar_id;/d" "$paciente_exame"
            fi


            echo ""
            while true; do
                read -p "Digite 1 para voltar: " caso
                if [ "$caso" == "1" ]; then
                    ./medico.sh
                    exit
                fi
            done
        else
            echo "---------------------------"
            echo ""
            echo -e "ID do usuário não encontrado."
            while true; do
                echo ""
                echo "Escolha uma opção:"
                echo "1. Tentar novamente"
                echo "2. Voltar"
                read caso
                clear

                if [ "$caso" == "1" ]; then
                    break
                elif [ "$caso" == "2" ]; then
                    ./medico.sh
                    exit
                else
                    echo "Opção inválida, tente novamente."
                fi
            done
            clear
        fi
    done

    log_info "O doctor $usuario realizou um exame"
}

function resultadoExame {
    clear
    figlet "Resultados dos Exames"
    echo ""
    echo -e "Digite os dados do paciente:"
    echo ""
    echo -e "Id do exame: "
    read procurar_id

    log_info "O doctor $usuario acessou a lista dos resultados dos exames"

    arquivo="$exame_feito"
    resultado=false
    if [ -s "$arquivo" ]; then
         while IFS=';' read -r id nome genero data_nascimento telefone data_consulta area estado medico pagamento nota; do
            if [ "$id" == "$procurar_id" ]; then
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
                 echo "-------------------"
                echo "$nota"
                echo "-------------------"
                resultado=true
            fi
        done <"$arquivo"

        if ! $resultado; then
            echo -e "Nenhum resultado do exame para o ID informado."
        fi
    else
        echo -e "Nenhum resultado do exame encontrada no arquivo."
    fi

    echo ""
    echo -e "1. Voltar"

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./medico.sh
            break
        else
            echo "Opção inválida, tente novamente."
        fi
    done

}  


function pacienteMorto {
    clear
    figlet "Marcar como Morto"
    echo ""
    echo -e "Digite os dados do morto:"
    echo ""

    log_info "O doctor $usuario acessou a sessão de mortalidade"

    while true; do
        echo -e "Id do exame: "
        read procurar_id

        echo -e "Causa da Morte: "
        read nota

        arquivo="$exame_feito"
        resultado=false
        linha_encontrada=""

        
        while IFS=';' read -r id nome genero data_nascimento telefone data_consulta area estado medico pagamento nota_antiga; do
            if [ "$id" == "$procurar_id" ]; then
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
                echo "-------------------"
                echo "Data da Morte: $data_morte=$(date +"%Y-%m-%d %H:%M:%S")"
                resultado=true
                linha_encontrada="$id;$nome;$genero;$data_nascimento;$telefone;$data_consulta;$area;$estado;$medico;$pagamento;$nota;$data_morte"
                break
            fi
        done < "$arquivo"

        if [ "$resultado" = true ]; then
        
         if grep -q "^$procurar_id;" "$paciente_morto"; then
            echo "Boletim de óbito com ID $procurar_id já foi registrado."
        else
            
            echo "$linha_encontrada" >> "$paciente_morto"
            echo "Boletim de óbito registrado com sucesso."
            log_info "O médico $medico registrou um boletim de óbito para o paciente $nome"

            
            if echo "$linha_encontrada" >> "$paciente_morto_historico"; then
                echo ""
            else
                echo "Erro ao salvar no histórico."
                log_error "Erro ao salvar boletim de óbito no histórico."
            fi
            sed -i "/^$procurar_id;/d" "$exame_feito"
        fi


            echo ""
            while true; do
                read -p "Digite 1 para voltar: " caso
                if [ "$caso" == "1" ]; then
                    ./medico.sh
                    exit
                fi
            done
        else
            echo "---------------------------"
            echo ""
            echo -e "ID do usuário não encontrado."
            while true; do
                echo ""
                echo "Escolha uma opção:"
                echo "1. Tentar novamente"
                echo "2. Voltar"
                read caso
                clear

                if [ "$caso" == "1" ]; then
                    break
                elif [ "$caso" == "2" ]; then
                    ./medico.sh
                    exit
                else
                    echo "Opção inválida, tente novamente."
                fi
            done
            clear
        fi
    done

    log_info "O doctor $usuario registrou um paciente como morto"
}

function boletimObito {
    clear
    figlet "Boletim de Obito"
    echo ""
            
    log_info "O doctor $usuario acessou ao boletim de obito"

    arquivo="$paciente_morto"

    if [ ! -f "$arquivo" ] || [ ! -s "$arquivo" ]; then
    echo -e "Boletim de obito vazio."
    echo ""
    echo -e "1. Voltar"
    echo ""

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./medico.sh
            break
        fi
    done
else
    echo ""
    
    consulta=0
    while IFS=';' read -r id nome genero data_nascimento telefone data_consulta area estado medico pagamento nota data_morte; do

        if [[ -n "${id// /}" ]]; then
         
            if [ "$medico" == "$usuario" ]; then
                consulta=1 
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
        fi
    done <"$arquivo"
    if [ $consulta -eq 0 ]; then
        echo "Não há boletim de obito para exibir."
    fi
fi

    echo ""
    echo -e "1. Voltar"
    echo ""

    while true; do
        read -p "Digite 1 para voltar: " caso

        if [ "$caso" == "1" ]; then
            ./medico.sh
            break
        fi
    done
}

clear
figlet "MEDICO"
echo ""
echo "Bem vindo/a $usuario"

echo " 
---------------------------------
| 1. Minhas Consultas           |
| 2. Realizar Consultas         |
| 3. Meus Resultados de Consulta| 			  
| 4. Meus Exames                |
| 5. Realizar Exames    	|
| 6. Meus Resultados de Exame   | 
| 7. Mortalidade         	|
| 8. Boletim de Obito           |
| 9. Sair     	  		|
--------------------------------
"
read opcao

echo ""

case $opcao in

1)
    minhasConsulta
    ;;
    
    
2)

     realizarConsulta
     ;;
     
3)
    resultadoConsulta
    ;;

4)  meusExames
    ;;

5) 
    realizarExame
    ;;

6)  
    resultadoExame
    ;;

7) 
    pacienteMorto
    ;;

8)  
    boletimObito
     ;;


9) cd ../login
    chmod a+x login.sh
    ./login.sh
   ;;
*)
    echo "Opcao nao disponivel, escolha um dos numeros apresentados!"
    echo ""
    ;;
esac

