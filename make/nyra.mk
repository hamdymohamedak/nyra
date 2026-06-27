# Nyra CLI binary — build once, reuse across smoke/test targets.
$(NYRA_BIN):
	@printf 'make: building nyra cli...\n'
	@cargo build -q -p cli

.PHONY: build-cli ensure-nyra
build-cli: $(NYRA_BIN)
ensure-nyra: build-cli
