
---

# AApanel-NodeJS-Simple-API

### Documentação: Configurando e Subindo o Projeto Node.js com aaPanel

Esta documentação guia o processo de configuração e deploy de um projeto Node.js usando aaPanel, subdomínios e um reverse proxy.

---

## **1. Requisitos**

Antes de iniciar, garanta que você tenha:

- **aaPanel** instalado e acessível
- **Nginx** configurado no servidor
- **Node.js** instalado no servidor

---

## **2. Estrutura do Projeto**

O projeto está estruturado da seguinte maneira:

```
/www/wwwroot/
└── subdominio.dominio.com/
    ├── public/
    │   └── index.html
    ├── src/
    │   └── app.js
    ├── package.json
    └── .gitignore
```

---

## **3. Configurando o aaPanel**

### 3.1. Criar o subdomínio

1. No painel do aaPanel, vá para **Website** e clique em **Add Site**.
2. Preencha o campo **Domain** com o subdomínio, por exemplo, `subdominio.dominio.com`.
3. Escolha o diretório `/www/wwwroot/subdominio.dominio.com` como o diretório raiz.
4. Selecione **Nginx** como o servidor da web.

### 3.2. Configurar Reverse Proxy

1. Após criar o site, vá para o **Gerenciador de Proxy** no aaPanel.
2. Ative o **Reverse Proxy** e configure-o com as seguintes informações:

```nginx
#PROXY-START/api

location ^~ /api/ {
    proxy_pass http://127.0.0.1:3000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header REMOTE-HOST $remote_addr;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    proxy_http_version 1.1;

    add_header X-Cache $upstream_cache_status;

    set $static_filebRVhh387 0;
    if ( $uri ~* "\.(gif|png|jpg|css|js|woff|woff2)$" ) {
        set $static_filebRVhh387 1;
        expires 1m;
    }
    if ( $static_filebRVhh387 = 0 ) {
        add_header Cache-Control no-cache;
    }
}
#PROXY-END/
```

Esse proxy garantirá que todas as requisições enviadas para `/api` no subdomínio sejam redirecionadas para o Node.js rodando na porta **3000**.

---

## **4. Subindo o Projeto**

### 4.1. Clonar ou criar o projeto

Navegue até o diretório raiz do subdomínio:

```bash
cd /www/wwwroot/subdominio.dominio.com
```

Clone ou crie o projeto no diretório desejado.

### 4.2. Instalar Dependências

Com o projeto configurado, execute:

```bash
npm install
```

### 4.3. Iniciar o Servidor Node.js

Inicie o servidor com o seguinte comando:

```bash
npm start
```

---

## **5. Configuração de Segurança e Otimização**

### 5.1. Configurando Certificados SSL

1. No aaPanel, vá para a seção **SSL** e habilite a geração de certificados gratuitos **Let's Encrypt** para o subdomínio.

### 5.2. Cache e Performance

Verifique a seção de cache no **Reverse Proxy** para ajustar a política de cache para arquivos estáticos (como CSS e JS).

---

## **6. Testando o Projeto**

### 6.1. Verificando o Status do Dashboard

Depois de subir o servidor, você pode testar o status do dashboard usando a rota **GET** para verificar quantas instâncias estão "open" ou "closed". 

Exemplo de requisição:

```bash
curl -X GET https://subdominio.dominio.com/api/status
```

Resposta esperada:

```json
{
  "openCount": 3,
  "closedCount": 99
}
```

### 6.2. Atualizando o Status das Instâncias

Você pode enviar uma requisição **POST** para atualizar o número de instâncias "open" e "closed". 

Exemplo de requisição **POST** para atualizar os dados:

```bash
curl -X POST https://subdominio.dominio.com/api/update-status \
-H "Content-Type: application/json" \
-d '{
  "openCount": 5,
  "closedCount": 10
}'
```

Resposta esperada:

```json
{
  "success": true,
  "message": "Dados atualizados com sucesso"
}
```

Isso atualiza as contagens das instâncias "open" e "closed" no servidor. Toda vez que o status for consultado com **GET**, os novos valores serão refletidos.

---

## **7. Automação com o n8n**

Se estiver integrando o projeto com ferramentas de automação como o **n8n**, você pode criar um fluxo que envie dados para o servidor automaticamente. Utilize um nó **HTTP Request** com a seguinte configuração:

- **Método:** POST
- **URL:** `https://subdominio.dominio.com/api/update-status`
- **Headers:** `Content-Type: application/json`
- **Body:** (modo JSON):

```json
{
  "openCount": {{$json["openCount"]}},
  "closedCount": {{$json["closedCount"]}}
}
```

---

## **8. Visualizando os Dados no Frontend**

Ao acessar `https://subdominio.dominio.com`, você verá um dashboard com os dados atualizados de "open" e "closed". O frontend foi configurado para atualizar automaticamente a cada 5 segundos:

```javascript
setInterval(updateCounts, 5 * 1000);  // Atualiza a cada 5 segundos
```

---

## **Formas Disponíveis para Subir o Projeto**



---

### **1. Via Script Automatizado**

Outra forma de automatizar o processo de configuração e execução do servidor é utilizando o script `script-modelo-template-boilerplate.sh`.

1. **Dar Permissão ao Script**:

```bash
chmod +x script-modelo-template-boilerplate.sh
```

2. **Executar o Script**:

```bash
./script-modelo-template-boilerplate.sh
```

Após a execução, basta iniciar o servidor com o comando:

```bash
sudo npm start
```

---

### **2. Usando o Painel Interativo do aaPanel**

1. **Adicionar um Serviço Node.js no aaPanel**:

- No painel do aaPanel, vá até a seção **App Store**.
- Instale o **Gerenciador de Node.js**.
- Após a instalação, acesse a aba **Application** e adicione uma nova aplicação Node.js.

2. **Configurar o Projeto Node.js**:

- Aponte o caminho da aplicação para o diretório do seu subdomínio: `/www/wwwroot/subdominio.dominio.com`.
- Defina a porta como **3000** ou outra configurada no projeto.
- Defina o caminho principal como `src/app.js` ou o arquivo principal do servidor como o path em `/`  .

3. **Executar o Projeto**:

- Após configurar a aplicação, o projeto pode ser iniciado diretamente pelo painel do aaPanel, o que deixará o **Node.js** rodando no servidor.

---

### **Recapitulando as Formas de Subir o Projeto:**

- **Via Terminal**: Instale as dependências e inicie o servidor manualmente.
- **Via Script**: Execute o script automatizado para configurar o projeto e rodar o servidor.
- **Via aaPanel (Painel Interativo)**: Use a interface gráfica para configurar e rodar o projeto Node.js.

--- 

Este guia cobre todas as etapas para configurar, rodar e automatizar seu projeto **Node.js** com aaPanel e **Nginx**.

