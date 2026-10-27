# Lummings: one entry point for every check. CI runs `make init lint test web-check`.
.PHONY: init lint test web-check benchmark docs format release

init:
	python -m pip install --upgrade pip && pip install -e ".[dev]" && cargo fetch

lint:
	python -m ruff check src tests scripts
	cargo clippy --workspace --all-targets -- -D warnings

test:
	python -m pytest tests -q
	cargo test --workspace

web-check:
	cd web && npm ci --no-audit --no-fund && npm run typecheck && npm run lint && npm test && npm run build

benchmark:
	cargo bench --workspace || true

docs:
	cargo doc --workspace --no-deps && echo "Build static website"

format:
	cargo fmt --all

release:
	cargo package --workspace || true
