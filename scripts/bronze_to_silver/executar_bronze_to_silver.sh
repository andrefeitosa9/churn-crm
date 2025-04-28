#!/bin/bash

read -p "Digite o usuário do banco de dados: " DB_USER
read -p "Digite o nome do banco de dados: " DB_NAME
read -s -p "Digite a senha para o usuário $DB_USER: " DB_PASSWORD
echo

export PGPASSWORD=$DB_PASSWORD

find ./ -name "*.sql" | grep -v "calculo_qtde_clientes_treino_teste.sql" | sort | while read script; do
    echo "Executando o script: $script"
    psql -U "$DB_USER" -d "$DB_NAME" -a -f "$script"
done

unset PGPASSWORD  # Limpa a variável depois de rodar
