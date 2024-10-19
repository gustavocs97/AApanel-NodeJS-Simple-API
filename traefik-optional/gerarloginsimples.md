Aqui está o tutorial completo que você pediu, com o título **generate_htpasswd_interactive+traefik.md**. O tutorial inclui as instruções para gerar um hash de senha interativo com a ferramenta `htpasswd` e como integrá-lo ao Traefik para autenticação básica.

---

# Autenticação Básica com `htpasswd` e Traefik

Este tutorial fornece uma explicação sobre como configurar autenticação básica no Traefik utilizando a ferramenta `htpasswd` para gerar senhas com hash. Também inclui um script para criar os hashes interativamente.

## Para logar ou deslogar:
Você pode utilizar a autenticação básica diretamente na URL:

```bash
http://user:password@subdomain.domain.com/
```

Isso permite que o navegador preencha as credenciais diretamente. No entanto, para deslogar, você precisará limpar o cache do navegador ou forçar a reautenticação, pois o HTTP Basic Auth não tem um método nativo de logout.

## Configurando Middleware de Autenticação no Traefik

Adicione o seguinte bloco de middleware no seu arquivo de configuração do Traefik para habilitar autenticação básica:

```yaml
# Middleware para autenticação básica
loginsimples:
  basicAuth:
    users:
      # Lista de usuários para autenticação básica
      - "usuario:hashgerado"
```

Substitua `usuario:hashgerado` pelo nome de usuário e o hash da senha gerado com o script abaixo.

---

## Script `generate_htpasswd_interactive.sh`

Esse script facilita a geração de hashes de senha utilizando a ferramenta `htpasswd`, com suporte ao formato Bcrypt. Ele também permite que você configure se deseja confirmar a senha ou não. O hash gerado é exibido e salvo em um arquivo com versões escapadas, prontas para serem usadas no Traefik.

### Código do Script:

```bash
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
```

### Como usar o script:

1. **Copie o código acima** para um arquivo chamado `generate_htpasswd_interactive.sh`.
2. **Dê permissão de execução** ao arquivo com o comando:

   ```bash
   chmod +x generate_htpasswd_interactive.sh
   ```

3. **Execute o script** no terminal:

   ```bash
   ./generate_htpasswd_interactive.sh
   ```

4. **Forneça o nome de usuário e a senha** conforme solicitado.
5. O hash gerado será exibido no terminal e salvo em um arquivo `htpasswd_hashes.txt`.

### Exemplo de Saída do Script:

- Hash gerado para uso direto:

  ```bash
  Hash sem escapar: $2y$05$G...hashoriginalgerado...
  ```

- Hash pronto para uso no Traefik (com o `$` escapado):

  ```bash
  Hash escapado para Traefik: $$2y$$05$$G...hashescapadogerado...
  ```

### Como Usar o Hash no Traefik:

Após gerar o hash com o script, copie o hash escapado e cole-o na configuração de middleware no Traefik, como mostrado abaixo:

```yaml
loginsimples:
  basicAuth:
    users:
      - "usuario:$$2y$$05$$G...hashescapadogerado..."
```

### Conclusão

Este processo permite que você adicione autenticação básica ao Traefik com segurança, utilizando senhas criptografadas com Bcrypt. O script interativo facilita a criação dos hashes, garantindo que eles estejam prontos para uso no Traefik.

---

Este é o passo a passo completo para implementar autenticação básica com `htpasswd` e Traefik.
