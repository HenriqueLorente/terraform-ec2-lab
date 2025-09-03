variable "aws_region" {
  type        = string
  default     = "sa-east-1"
  description = "Região AWS"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Tipo da instância"
}

variable "ingress_cidr" {
  type        = string
  default     = "0.0.0.0/0" # para lab; em prod use SEU_IP/32
  description = "CIDR permitido no HTTP/SSH"
}

/* IDs copiados do Console — evita Describe* */
variable "vpc_id" {
  type        = string
  description = "VPC ID (ex.: vpc-xxxxxxxx)"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID (ex.: subnet-xxxxxxxx)"
}

variable "ami_id" {
  type        = string
  description = "AMI ID (ex.: ami-xxxxxxxxxxxx — Amazon Linux 2023 x86_64)"
}

/* SSH opcional: informe o nome de um Key Pair já existente; senão deixe "" */
variable "key_name" {
  type        = string
  default     = ""
  description = "Nome do Key Pair existente (opcional)"
}

/* Se não puder criar SG por permissão, use false (cai no SG default da VPC) */
variable "create_sg" {
  type        = bool
  default     = true
  description = "Cria Security Group via Terraform?"
}

variable "security_group_id" {
  type        = string
  default     = ""
  description = "ID de um Security Group existente (sg-...) para anexar na instância"
}
