.PHONY: help docs-lint docs-links

help:
	@echo "Alvos disponíveis:"
	@echo "  make docs-lint   Valida Markdown localmente (requer markdownlint-cli2)"
	@echo "  make docs-links  Verifica links locais da documentação"

docs-lint:
	markdownlint-cli2 "**/*.md"

docs-links:
	@echo "A verificação de links é executada pelo workflow de documentação."

