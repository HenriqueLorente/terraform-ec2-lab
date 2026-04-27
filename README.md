# terraform-ec2-lab

Lab mínimo em **Terraform** para criar uma **instância EC2** na AWS (com **Amazon Linux**), subir um **Nginx** via `user_data` e expor o IP/URL como *outputs*.  
O código foi pensado para **ambientes com permissões restritas** (ex.: AWS Academy), por isso **não usa `data "aws_*"`** nem chamadas `Describe*`. Você informa **VPC, Subnet, AMI, Security Group e Key Pair** diretamente.

> ✅ Testado no **WSL/Ubuntu** e em **us-east-1**.  
> ✅ Funciona também em outras regiões (ajuste os IDs).

---

## 📦 O que este projeto cria

- 1x **EC2** (`t2.micro` por padrão) com **IP público**  
- **User Data** que instala e inicia **Nginx** com uma página simples  
- **Outputs** com `public_ip`, `public_dns` e `http_url`  

> **Opcional**: usar um **Security Group existente** ou deixar a instância no **SG default** (caso não possa criar SGs).

---

## 🗂️ Estrutura do repositório
terraform-ec2-lab/
├─ aws/ # (opcional) materiais adicionais
├─ .gitignore
├─ main.tf # provider + EC2 (sem data sources)
├─ outputs.tf # IP/URL/DNS
├─ user_data.sh # instala Nginx e publica uma página
├─ variables.tf # variáveis de entrada
└─ versions.tf # versões do Terraform e provider


---

## ✅ Pré-requisitos

- **Conta AWS** com permissão de **RunInstances** (e, se possível, criar SG).  
- **AWS CLI** configurado (perfil com acesso à conta/role que você usará).  
- **Terraform** ≥ 1.5.  
- **IDs da região escolhida**:
  - `vpc_id` (ex.: `vpc-...`)
  - `subnet_id` (da mesma VPC; preferir **subnet pública**)
  - `ami_id` (ex.: Amazon Linux 2023 x86_64 publicado na região)
  - `security_group_id` (se for usar SG existente)
  - `key_name` (nome do Key Pair existente, se quiser **SSH**)

> ⚠️ **Tudo é regional**: VPC/Subnet/SG/Key Pair/AMI devem ser da **mesma região**.

---

## ⚙️ Variáveis principais

| Variável             | Tipo   | Default      | Descrição |
|----------------------|--------|--------------|-----------|
| `aws_region`         | string | `sa-east-1`  | Região AWS (ex.: `us-east-1`) |
| `instance_type`      | string | `t2.micro`   | Tipo da instância |
| `ingress_cidr`       | string | `0.0.0.0/0`  | **Somente** se você optar por criar SG e abrir portas (lab) |
| `vpc_id`             | string | —            | **VPC ID** da região |
| `subnet_id`          | string | —            | **Subnet ID** (da mesma VPC) |
| `ami_id`             | string | —            | **AMI ID** (ex.: Amazon Linux 2023 x86_64) |
| `key_name`           | string | `""`         | Nome do **Key Pair** existente (opcional; para SSH) |
| `create_sg`          | bool   | `true`       | Tenta **criar** SG via Terraform (pode falhar em ambientes restritos) |
| `security_group_id`  | string | `""`         | **SG existente** para usar quando `create_sg=false` |

> O `provider "aws"` está configurado com `profile = "outra-conta"`.  
> Se preferir, remova essa linha e use `export AWS_PROFILE=<perfil>` no shell.

---

## 🚀 Como usar

### 1) Inicializar
```bash
terraform init
terraform fmt
terraform validate


Cenários de execução
A) Usando SG existente (recomendado para ambientes restritos)

Não cria SG; usa o ID informado (que já deve liberar 80/TCP e, se quiser SSH, 22/TCP).

terraform apply -auto-approve \
  -var "aws_region=us-east-1" \
  -var "vpc_id=vpc-xxxxxxxx" \
  -var "subnet_id=subnet-xxxxxxxx" \
  -var "ami_id=ami-xxxxxxxxxxxx" \
  -var "key_name=<seu_keypair>" \
  -var "create_sg=false" \
  -var "security_group_id=sg-xxxxxxxx"


B) Deixando no SG default da VPC

Não cria SG e não informa security_group_id. A EC2 herda o SG default da VPC (normalmente não tem HTTP aberto; abra a porta 80 no Console se puder).

terraform apply -auto-approve \
  -var "aws_region=us-east-1" \
  -var "vpc_id=vpc-xxxxxxxx" \
  -var "subnet_id=subnet-xxxxxxxx" \
  -var "ami_id=ami-xxxxxxxxxxxx" \
  -var "key_name=<seu_keypair>" \
  -var "create_sg=false"


C) Criando SG via Terraform (pode requerer ec2:CreateSecurityGroup)

terraform apply -auto-approve \
  -var "aws_region=us-east-1" \
  -var "vpc_id=vpc-xxxxxxxx" \
  -var "subnet_id=subnet-xxxxxxxx" \
  -var "ami_id=ami-xxxxxxxxxxxx" \
  -var "key_name=<seu_keypair>" \
  -var "create_sg=true"



🔎 Testes rápidos

Após o apply, pegue os outputs:

terraform output
# http_url, public_dns, public_ip


Testar HTTP:

curl $(terraform output -raw http_url)

SSH (se informou key_name e o SG libera 22/TCP):

# Exemplo no WSL usando .pem do Windows:
chmod 400 /mnt/c/Users/<SEU_USUARIO_WINDOWS>/Downloads/<seu_keypair>.pem
ssh -i /mnt/c/Users/<SEU_USUARIO_WINDOWS>/Downloads/<seu_keypair>.pem ec2-user@$(terraform output -raw public_ip)


Verificar user-data / Nginx via SSH:

sudo tail -n 200 /var/log/cloud-init-output.log
systemctl status nginx


🧹 Destruir o ambiente


terraform destroy -auto-approve \
  -var "aws_region=us-east-1" \
  -var "vpc_id=vpc-xxxxxxxx" \
  -var "subnet_id=subnet-xxxxxxxx" \
  -var "ami_id=ami-xxxxxxxxxxxx" \
  -var "key_name=<seu_keypair>" \
  -var "create_sg=false" \
  -var "security_group_id=sg-xxxxxxxx"


🛡️ Segurança & Custos

ingress_cidr = "0.0.0.0/0" é apenas para laboratório. Em produção use seu IP/32.

Key Pair: proteja seu .pem (chmod 400). Nunca faça commit do .pem.

Custos: t2.micro pode ser elegível ao free-tier, mas verifique sua conta/região.

🧩 Solução de problemas

InvalidAMIID.NotFound → AMI não existe na região. Use um AMI da mesma região.

InvalidKeyPair.NotFound → key_name não existe na região. Crie/seleciona um Key Pair nessa região.

UnauthorizedOperation: ec2:CreateSecurityGroup → sem permissão p/ criar SG. Use create_sg=false e security_group_id.

Sem acesso HTTP → abra Inbound 80/TCP no SG usado.

RunInstances AccessDenied → limitação da conta/curso (AWS Academy).

📌 Notas

O provider "aws" usa profile = "outra-conta". Alternativa:

export AWS_PROFILE=<seu-perfil>
# e remova a linha 'profile' do provider no main.tf


Não usamos data "aws_*" para compatibilidade com ambientes que bloqueiam Describe*.
-----------------------------------------------------------------------------------
