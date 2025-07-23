#!/bin/bash

# Script de deploy manual para VPS
# Usage: ./scripts/deploy.sh

set -e

# Carregar variáveis do arquivo .env se existir
if [ -f .env ]; then
    echo "📄 Carregando variáveis do arquivo .env..."
    export $(cat .env | grep -v '^#' | xargs)
fi

# Configurações (altere conforme necessário)
IMAGE_NAME="${DOCKERHUB_USERNAME:-jrnunes1993}/tdc-php-app"
CONTAINER_NAME="php-app-container"
VPS_PORT="80"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 Iniciando deploy da aplicação PHP...${NC}"

# Verificar se as variáveis de ambiente estão definidas
if [ -z "$VPS_HOST" ] || [ -z "$VPS_USER" ] || [ -z "$VPS_SSH_KEY" ]; then
    echo -e "${RED}❌ Erro: Defina as variáveis de ambiente:${NC}"
    echo "export VPS_HOST='seu_ip_aqui'"
    echo "export VPS_USER='seu_usuario_aqui'"
    echo "export VPS_SSH_KEY='conteudo_da_sua_chave_privada'"
    echo ""
    echo "Ou configure no GitHub: Settings > Secrets and variables > Actions"
    echo "- VPS_HOST: IP do seu VPS"
    echo "- VPS_USER: Usuário do VPS"
    echo "- VPS_SSH_KEY: Conteúdo da chave privada SSH"
    exit 1
fi

# Build da imagem Docker
echo -e "${YELLOW}🔨 Fazendo build da imagem Docker...${NC}"
docker build -t $IMAGE_NAME:latest .

# Teste local da imagem
echo -e "${YELLOW}🧪 Testando container localmente...${NC}"
docker run -d --name test-container -p 8081:80 $IMAGE_NAME:latest
sleep 5

if curl -f http://localhost:8081 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Teste local passou!${NC}"
else
    echo -e "${RED}❌ Teste local falhou!${NC}"
    docker stop test-container 2>/dev/null || true
    docker rm test-container 2>/dev/null || true
    exit 1
fi

docker stop test-container
docker rm test-container

# Push para Docker Hub
echo -e "${YELLOW}📤 Enviando imagem para Docker Hub...${NC}"
if [ -z "$DOCKERHUB_USERNAME" ] || [ -z "$DOCKERHUB_TOKEN" ]; then
    echo -e "${YELLOW}⚠️  Credenciais Docker Hub não configuradas. Fazendo login manual...${NC}"
    echo "Por favor, faça login no Docker Hub:"
    docker login
else
    echo "$DOCKERHUB_TOKEN" | docker login -u $DOCKERHUB_USERNAME --password-stdin
fi

docker push $IMAGE_NAME:latest

# Configurar SSH
echo -e "${YELLOW}🔑 Configurando SSH...${NC}"
mkdir -p ~/.ssh
echo "$VPS_SSH_KEY" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
ssh-keyscan -H $VPS_HOST >> ~/.ssh/known_hosts

# Deploy no VPS
echo -e "${YELLOW}🚀 Fazendo deploy no VPS...${NC}"
ssh -i ~/.ssh/id_rsa $VPS_USER@$VPS_HOST '
    # Verificar se Docker está instalado
    echo "🔍 Verificando se Docker está instalado..."
    if ! command -v docker &> /dev/null; then
        echo "❌ ERRO: Docker não está instalado no VPS!"
        echo "📋 Para instalar Docker, execute no VPS:"
        echo "   curl -fsSL https://get.docker.com -o get-docker.sh"
        echo "   sudo sh get-docker.sh"
        echo "   sudo usermod -aG docker $USER"
        exit 1
    else
        echo "✅ Docker está instalado"
    fi
    
    # Verificar se usuário está no grupo docker
    if ! groups | grep -q docker; then
        echo "❌ ERRO: Usuário não está no grupo docker!"
        echo "📋 Para adicionar ao grupo, execute no VPS:"
        echo "   sudo usermod -aG docker $USER"
        echo "   newgrp docker"
        exit 1
    else
        echo "✅ Usuário está no grupo docker"
    fi
    
    # Parar e remover container anterior
    echo "Parando container anterior..."
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
    
    # Remover imagem anterior
    echo "Removendo imagem anterior..."
    docker rmi $IMAGE_NAME:latest 2>/dev/null || true
    
    # Fazer pull da nova imagem do Docker Hub
    echo "Baixando nova imagem do Docker Hub..."
    docker pull $IMAGE_NAME:latest
    
    # Executar novo container
    echo "Iniciando novo container..."
    docker run -d \
        --name $CONTAINER_NAME \
        --restart unless-stopped \
        -p $VPS_PORT:80 \
        $IMAGE_NAME:latest
        
    # Verificar status
    echo "Verificando status do container..."
    docker ps | grep $CONTAINER_NAME
    
    echo "✅ Deploy realizado com sucesso!"
'

# Limpar arquivos temporários
rm ~/.ssh/id_rsa

echo -e "${GREEN}🎉 Deploy concluído com sucesso!${NC}"
echo -e "${GREEN}🌐 Aplicação disponível em: http://$VPS_HOST${NC}" 