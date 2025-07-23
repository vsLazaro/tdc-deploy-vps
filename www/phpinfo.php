<?php
// Este arquivo é apenas para debug
// REMOVA EM PRODUÇÃO!

// Verificar se não está em produção
if (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'localhost') === false) {
    die('Acesso negado em produção');
}

phpinfo();
?> 