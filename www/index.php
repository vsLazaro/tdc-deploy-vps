<?php
// Deploy automatizado funcionando! - $(date)
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Aplicação PHP - Deploy Automatizado</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
        }
        .info {
            background: #e8f4fd;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
        .success {
            background: #d4edda;
            color: #155724;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Aplicação PHP Funcionando!</h1>
            <p>Deploy automatizado via GitHub Actions</p>
        </div>

        <div class="success">
            <strong>✅ Container PHP está rodando com sucesso!</strong>
        </div>

        <div class="info">
            <h3>Informações do Sistema:</h3>
            <ul>
                <li><strong>Versão PHP:</strong> <?php echo phpversion(); ?></li>
                <li><strong>Servidor:</strong> <?php echo $_SERVER['SERVER_SOFTWARE']; ?></li>
                <li><strong>Data/Hora:</strong> <?php echo date('d/m/Y H:i:s'); ?></li>
                <li><strong>Host:</strong> <?php echo gethostname(); ?></li>
            </ul>
        </div>

        <div class="info">
            <h3>Como usar:</h3>
            <ol>
                <li>Coloque seus arquivos PHP no diretório <code>www/</code></li>
                <li>Faça commit e push para o repositório</li>
                <li>O GitHub Actions fará o deploy automaticamente</li>
            </ol>
        </div>

        <div class="info">
            <h3>Extensões PHP Instaladas:</h3>
            <p><?php echo implode(', ', get_loaded_extensions()); ?></p>
        </div>
    </div>
</body>
</html> 