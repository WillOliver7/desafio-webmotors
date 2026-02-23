# 🏎️ Desafio Webmotors Scraper

Este é um sistema distribuído em microsserviços para realizar web scraping de anúncios da Webmotors. O sistema permite que usuários se cadastrem, façam login e acompanhem suas tarefas de coleta de dados de forma isolada.
🏗️ Arquitetura

O projeto é composto por:

    Auth Service (Porta 3001): Gerencia usuários e autenticação via JWT (Cookies HttpOnly).

    Webscraping Manager (Porta 3003): Gerencia a criação de tarefas, persistência no banco e fila de processamento.

    Worker (Sidekiq): Processa o scraping em segundo plano.

    Redis: Broker de mensagens para o Sidekiq.

    PostgreSQL: Banco de dados para usuários e tarefas.

    Frontend: Single Page Application (SPA) em JavaScript Puro.

## 🚀 Como Rodar o Projeto
#### 1. Pré-requisitos

    Docker

    Docker Compose

#### 2. Configurando as Variáveis de Ambiente

Os serviços compartilham uma chave secreta (JWT_SECRET) para garantir que o token gerado por um possa ser lido pelo outro.

###### Como gerar uma chave segura:

Abra o seu terminal e rode o comando abaixo para gerar uma string aleatória de 64 caracteres:
Bash

ruby -e "require 'securerandom'; puts SecureRandom.hex(64)"

Criando o arquivo .env:
Crie um arquivo chamado .env na raiz do projeto (onde está o docker-compose.yml) e cole a chave gerada:

```
JWT_SECRET=cole_a_chave_gerada_aqui
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
```

#### 3. Subindo os Containers

Na raiz do projeto, execute:
Bash

docker-compose up -d --build

Isso irá buildar as imagens, instalar as gems e subir todos os serviços.

#### 4. Preparando o Banco de Dados

Com os containers rodando, você precisa criar as tabelas nos bancos de dados de autenticação e gerenciamento:
Bash

###### Migrations do Auth Service
docker exec -it desafio-webmotors-auth-service-1 bundle exec rails db:create db:migrate

###### Migrations do Webscraping Manager
docker exec -it desafio-webmotors-webscraping-manager-1 bundle exec rails db:create db:migrate

#### 5. Acessando o Projeto

Abra o seu navegador e acesse:

    Frontend: http://localhost:8080 (ou a porta definida no seu servidor estático).

    Sidekiq Dashboard: http://localhost:3003/sidekiq (opcional, se configurado).

🛠️ Comandos Úteis

Ver logs do Sidekiq (Worker):
Bash

docker logs -f desafio-webmotors-sidekiq-1

Reiniciar um serviço específico:
Bash

docker-compose restart webscraping-manager

Acessar o console do Rails para debug:
Bash

docker exec -it desafio-webmotors-auth-service-1 rails c

🔒 Segurança

    Os tokens de autenticação são armazenados em Cookies HttpOnly, protegendo contra ataques XSS.

    Cada usuário só tem acesso às tarefas que ele mesmo criou via escopo de user_id.
