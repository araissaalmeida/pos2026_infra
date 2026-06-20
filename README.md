# POSWEB 2026 - Infra, API e Frontend

Este repositório sobe uma aplicação simples com:

- EC2 Ubuntu para hospedar API Flask e frontend Nginx.
- RDS MySQL para armazenar os dados.
- Terraform para provisionar a infraestrutura.
- GitHub Actions para publicar backend e frontend automaticamente a cada push na branch `main`.

## 1. Criar seu repositório

1. Crie um repositório público no GitHub.
2. Clone ou copie a base da disciplina.
3. Configure o remoto do seu repositório:

```bash
git remote set-url origin https://github.com/SEU_USUARIO/SEU_REPOSITORIO.git
git push -u origin main
```

Confirme no GitHub que as pastas `.github`, `backend`, `db`, `frontend` e `iac` aparecem no seu repositório.

## 2. Criar infraestrutura com Terraform

Antes de executar, configure suas credenciais AWS localmente:

```bash
aws configure
```

Depois rode:

```bash
cd iac
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Ao final, anote os outputs:

- `app_public_ip`: IP publico da EC2.
- `db_endpoint`: host do RDS.
- `db_name`: nome do banco.
- `db_username`: usuario do banco.

Na console web da AWS, demonstre:

- EC2 > Instances: instancia criada.
- RDS > Databases: banco MySQL criado.
- EC2 > Security Groups: regras para SSH, HTTP, API e MySQL.

## 3. Alimentar o banco com dados iniciais

Copie o script SQL para a EC2:

```bash
scp -i iac/posweb-myapp-2026.pem db/db.sql ubuntu@APP_PUBLIC_IP:/home/ubuntu/db.sql
```

Acesse a EC2:

```bash
ssh -i iac/posweb-myapp-2026.pem ubuntu@APP_PUBLIC_IP
```

Execute o seed no RDS:

```bash
mysql -h DB_ENDPOINT -u myapp_user -p < /home/ubuntu/db.sql
```

Senha configurada no Terraform: `myapp_passwd`.

Valide:

```bash
mysql -h DB_ENDPOINT -u myapp_user -p -e "USE myapp; SELECT * FROM People;"
```

## 4. Colocar a API no ar

Configure estes secrets no GitHub em `Settings > Secrets and variables > Actions`:

- `HOST`: IP publico da EC2.
- `USERNAME`: `ubuntu`.
- `KEY`: conteudo completo da chave `.pem`.
- `DB_USERNAME`: `myapp_user`.
- `DB_PASSWORD`: `myapp_passwd`.
- `DB_HOST`: endpoint do RDS sem `:3306`.
- `DB_NAME`: `myapp`.

Faca um push para a branch `main` ou execute o workflow manualmente em `Actions > Deploy MyAPP > Run workflow`.

O GitHub Actions vai:

1. Substituir os placeholders em `backend/myapi.py`.
2. Copiar a API para `/home/ubuntu/myapp/myapi.py`.
3. Criar ou atualizar o servico `systemd` chamado `myapp`.
4. Reiniciar a API automaticamente.

Teste:

```bash
curl http://APP_PUBLIC_IP:5000/people
```

## 5. Colocar o frontend no ar

O mesmo workflow tambem:

1. Substitui `_API_ADDRESS_` em `frontend/index.html`.
2. Copia o arquivo para `/var/www/html/index.html`.
3. Recarrega o Nginx.

Acesse:

```text
http://APP_PUBLIC_IP
```

## 6. Demonstrar a aplicacao funcionando

Na apresentacao, mostre:

1. Pagina web carregando em `http://APP_PUBLIC_IP`.
2. A tabela com o registro inicial `John`.
3. Cadastro de uma nova pessoa pelo formulario.
4. Edicao de uma pessoa.
5. Remocao de uma pessoa.
6. Chamada direta na API:

```bash
curl http://APP_PUBLIC_IP:5000/people
```

## 7. Demonstrar deploy automatico com GitHub Actions

Faca uma alteracao simples no frontend, por exemplo no titulo do `frontend/index.html`.

Depois:

```bash
git add frontend/index.html
git commit -m "Atualiza titulo do frontend"
git push
```

Abra `Actions` no GitHub e mostre o workflow executando com sucesso. Em seguida, recarregue:

```text
http://APP_PUBLIC_IP
```

A alteracao feita no codigo deve aparecer na aplicacao publicada.

## Cuidados

- Nao faca commit de arquivos `.pem`, `.terraform/` ou `terraform.tfstate`.
- Ao terminar a atividade, execute `terraform destroy` para evitar cobranca na AWS.
