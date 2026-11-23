#!/usr/bin/env python3
"""
Script de geração de senhas criptograficamente seguras para o Extensopedia.
Atende aos requisitos NF010 e NF011.

Uso:
    python scripts/generate-passwords.py --env-file infra/.env
    python scripts/generate-passwords.py --print-only
    python scripts/generate-passwords.py --help
"""
import argparse
import os
import re
import secrets
import string
import sys
from pathlib import Path

DEFAULT_LENGTH = 32
# Conjunto de caracteres seguro para connection strings e arquivos .env
SAFE_CHARS = string.ascii_letters + string.digits + "_-."


def generate_secure_password(length: int = DEFAULT_LENGTH) -> str:
    """Gera uma senha forte usando o módulo secrets (CSPRNG)."""
    # Garante que contenha pelo menos maiúscula, minúscula e dígito
    while True:
        pwd = "".join(secrets.choice(SAFE_CHARS) for _ in range(length))
        has_upper = any(c.isupper() for c in pwd)
        has_lower = any(c.islower() for c in pwd)
        has_digit = any(c.isdigit() for c in pwd)
        if has_upper and has_lower and has_digit:
            return pwd


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Gera senhas fortes criptograficamente para variáveis de ambiente."
    )
    parser.add_argument(
        "--env-file",
        type=str,
        default="infra/.env",
        help="Caminho do arquivo .env de destino (padrão: infra/.env).",
    )
    parser.add_argument(
        "--template",
        type=str,
        default="infra/.env.example",
        help="Caminho do arquivo de exemplo/template (padrão: infra/.env.example).",
    )
    parser.add_argument(
        "--force",
        "-f",
        action="store_true",
        help="Sobrescreve o arquivo .env se ele já existir.",
    )
    parser.add_argument(
        "--print-only",
        action="store_true",
        help="Apenas exibe as senhas geradas no terminal sem gravar arquivo.",
    )
    parser.add_argument(
        "--length",
        type=int,
        default=DEFAULT_LENGTH,
        help=f"Comprimento das senhas geradas (padrão: {DEFAULT_LENGTH}).",
    )

    args = parser.parse_args()

    admin_pass = generate_secure_password(args.length)
    migration_pass = generate_secure_password(args.length)
    app_pass = generate_secure_password(args.length)

    if args.print_only:
        print("=== Senhas Fortes Geradas (NF010/NF011) ===")
        print(f"POSTGRES_PASSWORD={admin_pass}")
        print(f"DB_MIGRATION_PASSWORD={migration_pass}")
        print(f"DB_APP_PASSWORD={app_pass}")
        return 0

    target_path = Path(args.env_file)
    template_path = Path(args.template)

    if target_path.exists() and not args.force:
        print(
            f"ERRO: O arquivo '{target_path}' já existe. "
            "Use --force para sobrescrever ou --print-only para apenas exibir.",
            file=sys.stderr,
        )
        return 1

    if not template_path.exists():
        print(
            f"ERRO: Template '{template_path}' não foi encontrado.",
            file=sys.stderr,
        )
        return 1

    content = template_path.read_text(encoding="utf-8")

    # Substitui os placeholders de senha pelas senhas geradas
    content = re.sub(
        r"^POSTGRES_PASSWORD=.*$",
        f"POSTGRES_PASSWORD={admin_pass}",
        content,
        flags=re.MULTILINE,
    )
    content = re.sub(
        r"^DB_MIGRATION_PASSWORD=.*$",
        f"DB_MIGRATION_PASSWORD={migration_pass}",
        content,
        flags=re.MULTILINE,
    )
    content = re.sub(
        r"^DB_APP_PASSWORD=.*$",
        f"DB_APP_PASSWORD={app_pass}",
        content,
        flags=re.MULTILINE,
    )

    target_path.parent.mkdir(parents=True, exist_ok=True)
    target_path.write_text(content, encoding="utf-8")

    print(f"SUCESSO: Arquivo '{target_path}' gerado com senhas seguras.")
    print("Credenciais configuradas:")
    print(" - POSTGRES_PASSWORD (Admin)")
    print(" - DB_MIGRATION_PASSWORD (Dono / Migrations)")
    print(" - DB_APP_PASSWORD (Aplicação - DML apenas)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
