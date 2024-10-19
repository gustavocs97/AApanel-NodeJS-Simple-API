#!/bin/bash

# Variável hardcoded para ativar ou desativar a confirmação de senha
CONFIRMATION="off"  # Altere para "on" para ativar a confirmação de senha

# Definindo o tipo de hash que será usado
hash=Bcrypt  # Atualmente, este valor está fixo para Bcrypt, pois o htpasswd usa Bcrypt com a flag -B.

# Solicita o nome de usuário
read -p "Digite o nome de usuário: " USER

# Se a confirmação estiver ativada, o script solicitará a senha duas vezes para garantir que elas sejam iguais
if [ "$CONFIRMATION" == "on" ]; then
    # Loop para solicitar a senha até que ela seja confirmada corretamente
    while true; do
        read -sp "Digite a senha desejada: " PASSWORD
        echo
        read -sp "Confirme a senha: " PASSWORD_CONFIRM
        echo

        # Verifica se a senha e a confirmação são iguais
        if [ "$PASSWORD" == "$PASSWORD_CONFIRM" ]; then
            break
        else
            echo "As senhas não coincidem. Tente novamente."
        fi
    done
else
    # Se a confirmação estiver desativada, a senha será solicitada apenas uma vez
    read -sp "Digite a senha desejada: " PASSWORD
    echo
fi

# Gera o hash da senha usando htpasswd com Bcrypt (-nB)
HASH=$(htpasswd -nB $USER <<< $PASSWORD)

# Remove o newline adicionado pelo htpasswd
HASH=$(echo $HASH | tr -d '\n')

# Exibe o hash sem escapamento
echo "Hash sem escapar: $HASH"

# Escapa o caractere $ para Traefik, substituindo por $$
ESCAPED_HASH=$(echo $HASH | sed 's/\$/\$\$/g')

# Exibe o hash escapado para ser usado no Traefik
echo "Hash escapado para Traefik: $ESCAPED_HASH"

# Salva ambos em um arquivo de texto
echo "Hash sem escapar: $HASH" > htpasswd_hashes.txt
echo "Hash escapado para Traefik: $ESCAPED_HASH" >> htpasswd_hashes.txt

# Informa que o processo foi concluído
echo "Hashes gerados e salvos em htpasswd_hashes.txt"
