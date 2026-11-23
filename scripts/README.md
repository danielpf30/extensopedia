# Scripts

Scripts de automação local, manutenção e integração com serviços externos.

## Scripts disponíveis

### `generate-passwords.py`

Gera senhas fortes criptograficamente utilizando o módulo `secrets` (CSPRNG) da biblioteca padrão do Python, em conformidade com os requisitos de segurança **NF010** e **NF011**.

#### Uso

```bash
# Gera o arquivo infra/.env preenchido com senhas fortes a partir de infra/.env.example:
python scripts/generate-passwords.py --env-file infra/.env

# Sobrescrever arquivo existente:
python scripts/generate-passwords.py --env-file infra/.env --force

# Apenas exibir as senhas geradas no terminal sem criar arquivo:
python scripts/generate-passwords.py --print-only

# Especificar tamanho customizado (padrão: 32 caracteres):
python scripts/generate-passwords.py --print-only --length 48
```

Ou através do atalho no Makefile:

```bash
make generate-secrets
```

### `generate-passwords.sh`

Versão em script shell POSIX para ambientes Unix/Linux que não possuem Python instalado, utilizando `openssl rand` ou `/dev/urandom` como fallback.
