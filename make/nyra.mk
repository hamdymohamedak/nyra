# Nyra CLI binary — build once, reuse across smoke/test targets.
$(NYRA_BIN):
	@printf 'make: building nyra cli + compiler-ffi...\n'
	@cargo build -q -p cli -p compiler-ffi

.PHONY: build-cli build-compiler-ffi ensure-nyra
build-compiler-ffi:
	@cargo build -q -p compiler-ffi
build-cli: $(NYRA_BIN)
ensure-nyra: build-cli
