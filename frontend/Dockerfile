# Etapa 1: Build da aplicação React
FROM node:22.14.0 AS builder
WORKDIR /app

# Copia os arquivos de dependências e instala
COPY package*.json ./
RUN npm install

# Copia o restante do código da aplicação
COPY . .

# Gera o build para produção (assumindo que a saída do Vite vai para a pasta "dist")
RUN npm run build

# Etapa 2: Imagem final para servir a aplicação com o "serve"
FROM node:22.14.0
WORKDIR /app

# Copia os arquivos gerados na etapa de build
COPY --from=builder /app/dist ./dist

# Instala o pacote "serve" globalmente para servir os arquivos estáticos
RUN npm install -g serve

# Expõe a porta desejada
EXPOSE 3001

# Comando para iniciar o servidor estático
CMD ["serve", "-s", "dist", "-l", "3001"]

