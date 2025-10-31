# 🐍 FastAPI Application

API simples desenvolvida em Python com FastAPI que serve como base para implementações de infraestrutura.

## 📋 Características

- Framework: **FastAPI** - Framework web moderno e rápido para Python
- Banco de Dados: **PostgreSQL** (via SQLAlchemy)
- Containerização: **Docker** com multi-stage build
- ASGI Server: **Uvicorn**

## 🚀 Execução Local

### Com Docker Compose (Recomendado)

```bash
docker-compose up -d
```

A aplicação estará disponível em: http://localhost:8000

### Manualmente

1. **Instale as dependências**:
```bash
pip install -r requirements.txt
```

2. **Configure as variáveis de ambiente**:
```bash
export DATABASE_URL="postgresql://user:password@localhost:5432/dbname"
```

3. **Execute a aplicação**:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## 📡 Endpoints

- `GET /do-you-have-it` - Retorna mensagem aleatória
- `GET /do-you-have-it-db` - Retorna string aleatória do banco de dados
- `GET /docs` - Documentação interativa (Swagger UI)
- `GET /redoc` - Documentação alternativa (ReDoc)

## 🐳 Docker

Para construir a imagem Docker:

```bash
docker build -t desafio-app -f docker/Dockerfile .
```

Para executar:

```bash
docker run -p 8000:8000 -e DATABASE_URL="postgresql://..." desafio-app
```
