#!/bin/bash

# Função para mostrar as configurações atuais
show_config() {
  echo ""
  echo "Configurações Selecionadas:"
  echo "==========================="
  echo "Diretório: $PROJECT_DIR"
  echo "Subdomínio: $SUBDOMAIN"
  echo "Domínio: $DOMAIN"
  echo "Porta: $PORT"
  echo "==========================="
  echo ""
}

# Obtém o diretório atual usando pwd
CURRENT_DIR=$(pwd)

# Tenta extrair o subdomínio e o domínio do diretório atual
DEFAULT_SUBDOMAIN=$(basename $CURRENT_DIR | cut -d. -f1)
DEFAULT_DOMAIN=$(basename $CURRENT_DIR | cut -d. -f2-)
DEFAULT_PORT=3000

# Configurações padrão
PROJECT_DIR=$CURRENT_DIR
SUBDOMAIN=$DEFAULT_SUBDOMAIN
DOMAIN=$DEFAULT_DOMAIN
PORT=$DEFAULT_PORT

# Mostrar configurações padrão e perguntar qual tipo de instalação o usuário deseja
echo "Instalação Expressa/Customizada para o Dashboard"
echo "Configurações Padrão:"
show_config

read -p "Deseja usar a instalação expressa (y) ou customizada (n)? (y/n): " installation_type

# Se o usuário escolher customizada, permite modificações
if [ "$installation_type" = "n" ]; then
  # Permite escolher um novo diretório
  read -p "Digite o caminho completo do diretório onde deseja instalar: " NEW_DIR
  if [ ! -z "$NEW_DIR" ]; then
    PROJECT_DIR=$NEW_DIR
  fi
  
  # Pergunta por novos subdomínio e domínio
  read -p "Digite o subdomínio (padrão: $DEFAULT_SUBDOMAIN): " NEW_SUBDOMAIN
  if [ ! -z "$NEW_SUBDOMAIN" ];then
    SUBDOMAIN=$NEW_SUBDOMAIN
  fi
  
  read -p "Digite o domínio (padrão: $DEFAULT_DOMAIN): " NEW_DOMAIN
  if [ ! -z "$NEW_DOMAIN" ]; then
    DOMAIN=$NEW_DOMAIN
  fi
  
  # Pergunta sobre a porta
  read -p "Deseja usar a porta padrão $DEFAULT_PORT? (y/n): " use_default_port
  if [ "$use_default_port" = "n" ]; then
    read -p "Digite a nova porta para o servidor: " CUSTOM_PORT
    if [ ! -z "$CUSTOM_PORT" ]; then
      PORT=$CUSTOM_PORT
    fi
  fi
else
  # Para a instalação expressa, não faz mais perguntas, usa as configurações padrão
  echo "Instalação expressa selecionada. Continuando com as configurações padrão..."
fi

# Mostra as configurações finais antes de prosseguir
echo "Configurações Finais:"
show_config

# Cria os diretórios necessários
mkdir -p $PROJECT_DIR/public
mkdir -p $PROJECT_DIR/src

# Gera os arquivos necessários

# Cria o arquivo package.json com scripts e dependências
cat <<EOF > $PROJECT_DIR/package.json
{
  "name": "${SUBDOMAIN}-dashboard",
  "version": "1.0.0",
  "description": "Dashboard para monitorar o status de instâncias em ${SUBDOMAIN}.${DOMAIN}",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js",
    "install-dependencies": "npm install"
  },
  "dependencies": {
    "express": "^4.17.1"
  }
}
EOF

# Cria o arquivo .gitignore para ignorar a pasta node_modules
echo "node_modules/" > $PROJECT_DIR/.gitignore

# Cria o arquivo app.js no diretório src com o servidor Express
cat <<EOF > $PROJECT_DIR/src/app.js
const express = require('express');
const path = require('path');

const app = express();
const port = $PORT;

// Contadores para "open" e "closed"
let openCount = 0;
let closedCount = 0;

// Configuração do diretório de arquivos estáticos
app.use(express.json());
app.use(express.static(path.join(__dirname, '../public')));

// Rota para consultar o status das instâncias
app.get('/api/status', (req, res) => {
  res.json({ openCount, closedCount });
});

// Rota para atualizar o status das instâncias
app.post('/api/update-status', (req, res) => {
  const { openCount: open, closedCount: closed } = req.body;
  
  // Verifica se os dados enviados são válidos
  if (typeof open === 'number' && typeof closed === 'number') {
    openCount = open;
    closedCount = closed;
    res.json({ success: true, message: 'Dados atualizados com sucesso' });
  } else {
    res.status(400).json({ success: false, message: 'Dados inválidos' });
  }
});

// Inicia o servidor
app.listen(port, () => {
  console.log(\`Servidor rodando na porta \${port}\`);
});
EOF

# Cria o arquivo index.html no diretório public para exibir os dados no frontend
cat <<EOF > $PROJECT_DIR/public/index.html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Status de Instâncias - ${SUBDOMAIN}.${DOMAIN}</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    h1 { color: #333; }
    .count { margin-top: 20px; font-size: 1.5em; }
  </style>
</head>
<body>
  <h1>Status de Instâncias</h1>
  <div class="count">
    <p><strong>Open Count:</strong> <span id="openCount">Carregando...</span></p>
    <p><strong>Closed Count:</strong> <span id="closedCount">Carregando...</span></p>
  </div>

  <script>
    function updateCounts() {
      fetch('/api/status')
        .then(response => response.json())
        .then(data => {
          document.getElementById('openCount').textContent = data.openCount;
          document.getElementById('closedCount').textContent = data.closedCount;
        })
        .catch(error => {
          console.error('Erro ao buscar dados:', error);
        });
    }

    updateCounts();
    setInterval(updateCounts, 5 * 1000); // Atualiza a cada 5 segundos
    
  </script>
</body>
</html>
EOF

# Pergunta ao usuário se ele deseja instalar as dependências
if [ "$installation_type" = "n" ]; then
  read -p "Deseja instalar as dependências agora? (y/n): " install_deps
else
  install_deps="y"  # Para instalação expressa, assume que o usuário quer instalar automaticamente
fi

if [ "$install_deps" = "y" ]; then
  cd $PROJECT_DIR
  npm install
  echo "Dependências instaladas com sucesso!"
else
  echo "Você pode instalar as dependências mais tarde rodando 'npm install'."
fi

echo "Projeto configurado com sucesso em ${SUBDOMAIN}.${DOMAIN} na porta ${PORT}!"
