const express = require('express');
const path = require('path');

const app = express();
const port = 3000;

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
  console.log(`Servidor rodando na porta ${port}`);
});
