#!/bin/bash

# Script de configuração inicial
# Usage: ./scripts/setup.sh

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Configuração Inicial do Projeto PHP${NC}"
echo "=================================="

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker não está instalado!${NC}"
    echo "Instale o Docker primeiro: https://docs.docker.com/get-docker/"
    exit 1
fi

echo -e "${GREEN}✅ Docker encontrado${NC}"

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker Compose não encontrado, instalando...${NC}"
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

echo -e "${GREEN}✅ Docker Compose encontrado${NC}"

# Criar arquivo .env se não existir
if [ ! -f .env ]; then
    echo -e "${YELLOW}📄 Criando arquivo .env...${NC}"
    cp example.env .env
    echo -e "${GREEN}✅ Arquivo .env criado${NC}"
    echo -e "${YELLOW}⚠️  IMPORTANTE: Edite o arquivo .env com suas configurações do VPS${NC}"
else
    echo -e "${GREEN}✅ Arquivo .env já existe${NC}"
fi

# Testar build da imagem
echo -e "${YELLOW}🔨 Testando build da imagem Docker...${NC}"
docker build -t php-app:test .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build da imagem bem-sucedido${NC}"
else
    echo -e "${RED}❌ Erro no build da imagem${NC}"
    exit 1
fi

# Testar container localmente
echo -e "${YELLOW}🧪 Testando container localmente...${NC}"
docker run -d --name setup-test -p 8082:80 php-app:test
sleep 5

if curl -f http://localhost:8082 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Container funcionando corretamente${NC}"
else
    echo -e "${RED}❌ Erro ao testar container${NC}"
fi

# Limpar teste
docker stop setup-test 2>/dev/null || true
docker rm setup-test 2>/dev/null || true
docker rmi php-app:test 2>/dev/null || true

echo ""
echo -e "${GREEN}🎉 Configuração concluída com sucesso!${NC}"
echo ""
echo -e "${BLUE}📋 Próximos passos:${NC}"
echo "1. Edite o arquivo .env com suas configurações do VPS"
echo "2. Configure os secrets no GitHub:"
echo "   - VPS_HOST: IP do seu VPS"
echo "   - VPS_USER: Usuário do VPS"
echo "   - VPS_SSH_KEY: Conteúdo da chave privada SSH"
echo "3. Adicione seus arquivos PHP no diretório www/"
echo "4. Faça commit e push para o repositório"
echo ""
echo -e "${BLUE}🧪 Para testar localmente:${NC}"
echo "docker-compose up -d"
echo "Acesse: http://localhost:8080"
echo ""
echo -e "${BLUE}🚀 Para fazer deploy manual:${NC}"
echo "./scripts/deploy.sh" 