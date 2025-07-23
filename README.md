# 🚀 Deploy PHP com GitHub Actions

Este projeto fornece uma estrutura completa para deploy automatizado de aplicações PHP usando GitHub Actions e Docker em um VPS.

## 📁 Estrutura do Projeto

```
tdc-deploy/
├── .github/workflows/
│   └── deploy.yml                 # Workflow GitHub Actions (2 jobs)
├── scripts/
│   ├── deploy.sh                  # Script de deploy manual
│   └── setup.sh                   # Script de configuração inicial
├── www/
│   ├── index.php                  # Página inicial
│   ├── .htaccess                  # Configurações Apache
│   └── phpinfo.php                # Debug (remover em produção)
├── docker-compose.yml             # Para desenvolvimento local
├── Dockerfile                     # Container PHP + Apache
├── example.env                    # Exemplo de variáveis de ambiente
├── .gitignore                     # Arquivos ignorados pelo Git
└── README.md                      # Este arquivo
```

## 🔧 Configuração Inicial

### 0. Setup Automático (Recomendado)

Execute o script de configuração automática:

```bash
./scripts/setup.sh
```

Este script irá:
- Verificar se Docker está instalado
- Instalar Docker Compose se necessário
- Criar arquivo .env baseado no example.env
- Testar o build da imagem
- Testar o container localmente

### 1. Preparar o VPS

**O Docker DEVE estar instalado no VPS antes do deploy:**

```bash
# No seu VPS (OBRIGATÓRIO)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
```

**Nota:** O workflow GitHub Actions verifica se o Docker está instalado e falha se não estiver.

### 2. Configurar Secrets no GitHub

No seu repositório GitHub, vá em **Settings > Secrets and variables > Actions** e adicione:

**Secrets obrigatórios:**
- `VPS_HOST`: IP do seu VPS (ex: `192.168.1.100`)
- `VPS_USER`: Usuário do VPS (ex: `ubuntu`)
- `VPS_SSH_KEY`: Conteúdo da sua chave privada SSH

**Secrets para Docker Hub:**
- `DOCKERHUB_USERNAME`: Seu usuário do Docker Hub
- `DOCKERHUB_TOKEN`: Seu token de acesso do Docker Hub

**Como obter a chave SSH:**

```bash
# 1. Gerar nova chave (se necessário)
ssh-keygen -t rsa -b 4096 -C "seu-email@exemplo.com"

# 2. Copiar chave pública para VPS
ssh-copy-id usuario@ip-do-vps

# 3. Mostrar chave privada para copiar no GitHub
cat ~/.ssh/id_rsa
```

**IMPORTANTE:** Copie TODO o conteúdo da chave privada (incluindo as linhas `-----BEGIN OPENSSH PRIVATE KEY-----` e `-----END OPENSSH PRIVATE KEY-----`) e cole no secret `VPS_SSH_KEY` do GitHub.

**Como obter token do Docker Hub:**
1. Acesse: https://hub.docker.com/settings/security
2. Clique em "New Access Token"
3. Dê um nome (ex: "github-actions")
4. Copie o token gerado
5. Cole no secret `DOCKERHUB_TOKEN` do GitHub

### 3. Configuração do Repositório

1. Fork ou clone este repositório
2. Execute `./scripts/setup.sh` para configuração inicial
3. Edite o arquivo `.env` com suas configurações do VPS
4. Configure os secrets no GitHub conforme acima
5. Adicione seus arquivos PHP no diretório `www/`
6. Faça push para a branch `main`

**Importante:** O deploy automático só acontece na branch `main`.

## 🚀 Deploy

### Deploy Automático

O deploy acontece automaticamente quando você faz push para a branch `main`:

#### **Job 1: Build & Push**
1. ✅ Build da imagem Docker
2. ✅ Teste local do container
3. ✅ Push para Docker Hub (latest + tag do commit)
4. ✅ Validação do código

#### **Job 2: Deploy (apenas na main)**
1. ✅ Pull da imagem do Docker Hub
2. ✅ Deploy no VPS
3. ✅ Atualização do container em produção
4. ✅ Resumo do deploy

**Nota:** O deploy só acontece na branch `main`. Outras branches fazem apenas build e validação.

### 🐳 Vantagens do Docker Hub

- ✅ **Mais rápido:** Não precisa transferir arquivos grandes via SCP
- ✅ **Mais confiável:** Usa a infraestrutura do Docker Hub
- ✅ **Mais profissional:** Imagem disponível publicamente
- ✅ **Cache eficiente:** Apenas camadas alteradas são baixadas
- ✅ **Versionamento:** Pode usar tags específicas (latest, v1.0, etc.)

### Deploy Manual

Você também pode fazer deploy manual:

```bash
# Opção 1: Usando variáveis de ambiente
export VPS_HOST="seu-ip-aqui"
export VPS_USER="seu-usuario"
export VPS_SSH_KEY="conteudo_da_chave_privada"

# Executar deploy
./scripts/deploy.sh
```

**OU**

```bash
# Opção 2: Usando arquivo .env (copie example.env)
cp example.env .env
# Edite o arquivo .env com suas configurações
./scripts/deploy.sh
```

## 🧪 Desenvolvimento Local

Para testar localmente:

```bash
# Usando Docker Compose (recomendado)
docker-compose up -d

# Ou build manual
docker build -t jrnunes1993/tdc-php-app .
docker run -p 8080:80 jrnunes1993/tdc-php-app

# Acessar: http://localhost:8080
```

**Nota:** Substitua `jrnunes1993` pelo seu usuário do Docker Hub.

## 📂 Adicionando Código PHP

1. Coloque seus arquivos PHP no diretório `www/`
2. Exemplo de estrutura:

```
www/
├── index.php          # Página inicial
├── api/
│   └── users.php      # API endpoints
├── includes/
│   └── config.php     # Configurações
└── assets/
    ├── css/
    └── js/
```

## 🔧 Customizações

### Dockerfile

Para adicionar extensões PHP ou modificar configurações, edite o `Dockerfile`:

```dockerfile
# Adicionar extensões
RUN docker-php-ext-install gd curl zip

# Configurações do PHP
COPY php.ini /usr/local/etc/php/
```

### Banco de Dados

O `docker-compose.yml` inclui MySQL para desenvolvimento. Para produção, configure separadamente no VPS.

### Domínio

Para usar um domínio, configure um proxy reverso (Nginx) no VPS:

```nginx
server {
    listen 80;
    server_name seudominio.com;
    
    location / {
        proxy_pass http://localhost:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🐛 Troubleshooting

### Container não inicia

```bash
# Verificar logs no VPS
docker logs php-app-container

# Verificar se porta está ocupada
sudo netstat -tlnp | grep :80

# Verificar se Docker está rodando
sudo systemctl status docker

# Verificar se usuário está no grupo docker
groups
```

### Erro de SSH

```bash
# Testar conexão SSH
ssh -i ~/.ssh/id_rsa usuario@ip-do-vps

# Verificar chave pública no VPS
cat ~/.ssh/authorized_keys
```

### Deploy falha

1. Verifique se os secrets estão configurados corretamente
2. **Confirme que o Docker está instalado no VPS** (obrigatório)
3. Verifique logs do GitHub Actions
4. Certifique-se de que o repositório existe no Docker Hub
5. Verifique se a branch é `main` (deploy só acontece na main)

### Erro: "Docker não está instalado no VPS"

Se você ver este erro, execute no VPS:

```bash
# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Verificar instalação
docker --version
```

## 📋 Comandos Úteis

```bash
# Verificar status no VPS
docker ps
docker logs php-app-container

# Parar aplicação
docker stop php-app-container

# Iniciar aplicação
docker start php-app-container

# Rebuild completo
docker stop php-app-container
docker rm php-app-container
docker rmi jrnunes1993/tdc-php-app:latest
# Depois faça novo deploy

# Verificar imagens disponíveis
docker images | grep tdc-php-app

# Ver logs do GitHub Actions
# Acesse: https://github.com/seu-usuario/seu-repo/actions
```

## 🔄 Workflow de 2 Jobs

O projeto usa um workflow otimizado com 2 jobs separados:

### **Job 1: build-and-push**
- ✅ Executa em todas as branches
- ✅ Build da imagem Docker
- ✅ Teste local do container
- ✅ Push para Docker Hub
- ✅ Validação do código

### **Job 2: deploy**
- ✅ Executa apenas na branch `main`
- ✅ Depende do sucesso do job 1
- ✅ Deploy automático no VPS
- ✅ Pull da imagem do Docker Hub
- ✅ Atualização do container

### **Vantagens:**
- 🚀 **Deploy seguro:** Apenas na branch principal
- 🔄 **CI/CD completo:** Build em todas as branches
- 📦 **Versionamento:** Tags automáticas por commit
- 🎯 **Controle:** Deploy controlado e previsível

## 🛡️ Segurança

- Mantenha suas chaves SSH seguras
- Use HTTPS em produção
- Configure firewall no VPS
- Atualize regularmente o sistema base
- Deploy apenas na branch `main`

## 📝 Licença

Este projeto é de uso livre. Modifique conforme necessário. 