# 🚀 Desafio DevOps - Loomi

Projeto de exemplo demonstrando práticas DevOps com uma aplicação FastAPI, infraestrutura como código usando Terraform, orquestração com Kubernetes (EKS) e CI/CD automatizado com GitHub Actions.

## 📋 Índice

- [Sobre o Projeto](#-sobre-o-projeto)
- [Arquitetura](#-arquitetura)
- [Tecnologias](#-tecnologias)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Pré-requisitos](#-pré-requisitos)
- [Como Usar](#-como-usar)
  - [Executar Localmente com Docker](#executar-localmente-com-docker)
  - [Deploy na AWS com Terraform](#deploy-na-aws-com-terraform)
  - [Deploy no Kubernetes (EKS)](#deploy-no-kubernetes-eks)
- [Endpoints da API](#-endpoints-da-api)
- [CI/CD](#-cicd)
- [Contribuindo](#-contribuindo)

## 🎯 Sobre o Projeto

Este projeto implementa uma API REST simples usando FastAPI que demonstra:
- Deploy de aplicação Python em containers Docker
- Infraestrutura automatizada na AWS (EC2, RDS, EKS)
- Orquestração de containers com Kubernetes
- Pipeline CI/CD com GitHub Actions
- Integração com banco de dados PostgreSQL

## 🏗️ Arquitetura

```
┌─────────────────┐
│  GitHub Actions │
│     (CI/CD)     │
└────────┬────────┘
         │
         ├──► Build Docker Image
         │    └──► Push to ECR
         │
         └──► Deploy to EKS
              │
              ├──► FastAPI App (Pods)
              └──► PostgreSQL RDS
```

### Componentes:

- **Aplicação**: API FastAPI em container Docker
- **Banco de Dados**: PostgreSQL (RDS na AWS)
- **Orquestração**: Kubernetes (EKS)
- **Infraestrutura**: Terraform (EC2, RDS, Security Groups)
- **CI/CD**: GitHub Actions

## 🛠️ Tecnologias

### Backend
- **Python 3.10**
- **FastAPI** - Framework web moderno e rápido
- **SQLAlchemy** - ORM para PostgreSQL
- **Uvicorn** - ASGI server

### Infraestrutura
- **Docker** - Containerização
- **Kubernetes** - Orquestração de containers
- **Terraform** - Infrastructure as Code
- **AWS Services**:
  - EKS (Elastic Kubernetes Service)
  - EC2 (Elastic Compute Cloud)
  - RDS (Relational Database Service)
  - ECR (Elastic Container Registry)
  - VPC (Virtual Private Cloud)

### DevOps
- **GitHub Actions** - CI/CD Pipeline
- **Docker Compose** - Orquestração local

## 📁 Estrutura do Projeto

```
desafio-devops-loomi/
├── app/                    # Aplicação FastAPI
│   ├── docker/
│   │   ├── Dockerfile      # Imagem Docker da aplicação
│   │   └── .dockerignore
│   ├── main.py             # Código principal da API
│   ├── requirements.txt    # Dependências Python
│   └── docker-compose.yml  # Orquestração local
│
├── infra/                  # Infraestrutura como código
│   └── ec2/
│       ├── main.tf         # Recursos principais (EC2, RDS)
│       ├── variables.tf    # Variáveis do Terraform
│       ├── outputs.tf      # Outputs do Terraform
│       └── providers.tf    # Configuração de providers
│
├── k8s/                    # Manifests Kubernetes
│   ├── deployment.yaml     # Deployment da aplicação
│   └── service.yaml        # Service (LoadBalancer)
│
├── .github/
│   └── workflows/
│       └── deploy.yml      # Pipeline CI/CD
│
├── .gitignore              # Arquivos ignorados pelo Git
└── README.md               # Este arquivo
```

## 📦 Pré-requisitos

### Local
- **Docker** e **Docker Compose**
- **Python 3.10+** (para desenvolvimento local)
- **Git**

### AWS Deploy
- **Terraform** >= 1.0
- **AWS CLI** configurado
- **kubectl** (para Kubernetes)
- Credenciais AWS configuradas
- Chave SSH para acesso às instâncias EC2

## 🚀 Como Usar

### Executar Localmente com Docker

1. **Clone o repositório**:
```bash
git clone <repo-url>
cd desafio-devops-loomi
```

2. **Entre no diretório da aplicação**:
```bash
cd app
```

3. **Inicie os serviços com Docker Compose**:
```bash
docker-compose up -d
```

4. **Acesse a API**:
- API: http://localhost:8000
- Documentação Swagger: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### Deploy na AWS com Terraform

1. **Configure as variáveis do Terraform**:
```bash
cd infra/ec2
```

2. **Inicialize o Terraform**:
```bash
terraform init
```

3. **Revise o plano de execução**:
```bash
terraform plan
```

4. **Aplique a infraestrutura**:
```bash
terraform apply
```

⚠️ **Nota**: Configure as variáveis necessárias antes de executar o `terraform apply`. Verifique o arquivo `variables.tf` para ver as variáveis requeridas.

### Deploy no Kubernetes (EKS)

O deploy automático é feito via GitHub Actions quando há push na branch `main`.

Para deploy manual:

1. **Configure o kubectl para o cluster EKS**:
```bash
aws eks update-kubeconfig --region us-east-1 --name <cluster-name>
```

2. **Aplique os manifests Kubernetes**:
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

3. **Verifique o status**:
```bash
kubectl get pods
kubectl get services
```

## 📡 Endpoints da API

### `GET /do-you-have-it`
Retorna uma mensagem aleatória da lista pré-definida.

**Resposta**:
```json
{
  "message": "You have it!"
}
```

### `GET /do-you-have-it-db`
Retorna uma string aleatória do banco de dados PostgreSQL.

**Requisitos**: Requer `DATABASE_URL` configurada.

**Resposta**:
```json
{
  "message": "String aleatória do banco"
}
```

## 🔄 CI/CD

O projeto utiliza GitHub Actions para automatizar o processo de deploy:

1. **Trigger**: Push na branch `main`
2. **Build**: Cria imagem Docker da aplicação
3. **Push**: Envia imagem para Amazon ECR
4. **Deploy**: Aplica manifests Kubernetes no cluster EKS
5. **Verificação**: Confirma que os pods estão rodando

### Secrets Necessários no GitHub

Configure os seguintes secrets no GitHub:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `ECR_REPOSITORY`
- `EKS_CLUSTER`

## 🔒 Segurança

⚠️ **Atenção**: Este é um projeto de exemplo. Para produção, considere:
- Usar variáveis de ambiente seguras (secrets management)
- Implementar autenticação/autorização na API
- Configurar HTTPS/TLS
- Revisar e restringir Security Groups
- Usar bancos de dados em subnets privadas
- Implementar logging e monitoramento

## 📝 Licença

Este projeto é um exemplo educacional para demonstração de práticas DevOps.

## 🤝 Contribuindo

Este é um projeto de desafio/exemplo. Sinta-se livre para fazer fork e adaptar para suas necessidades!

---

**Desenvolvido para demonstrar práticas DevOps**

