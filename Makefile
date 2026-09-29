.PHONY: init lint test benchmark docs format release

init:
	python -m pip install --upgrade pip && pip install -e ".[dev]" && cargo fetch

lint:
	cargo clippy --workspace --all-targets -- -D warnings

test:
	cargo test --workspace

benchmark:
	cargo bench --workspace || true

docs:
	cargo doc --workspace --no-deps && echo "Build static website"

format:
	cargo fmt --all

release:
	cargo package --workspace || true
