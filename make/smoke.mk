# Smoke tests — stdlib, examples, CLI, apps, cross-compile, Sonic.

.PHONY: smoke-cli smoke-apps smoke-database smoke-sqlite
.PHONY: smoke-stdlib smoke-stdlib-priority smoke-stdlib-medium
.PHONY: smoke-corpus smoke-examples smoke-serde-pkg smoke-cross smoke-sonic smoke-enterprise
.PHONY: smoke-vscode-extension smoke-runtime smoke-cross-wasm smoke-cross-linux smoke-cross-windows
.PHONY: test-runtime-smoke

smoke-cli: ensure-nyra
	@$(MAKE_LIB)/cli-smoke.sh

smoke-apps: ensure-nyra
	@$(MAKE_LIB)/apps-smoke.sh

smoke-database: ensure-nyra
	@$(MAKE_LIB)/database-smoke.sh

smoke-sqlite: ensure-nyra
	@$(MAKE_LIB)/sqlite-smoke.sh

smoke-stdlib: ensure-nyra
	@$(MAKE_LIB)/stdlib-smoke.sh

smoke-stdlib-priority: ensure-nyra
	@$(MAKE_LIB)/stdlib-priority-smoke.sh

smoke-stdlib-medium: ensure-nyra
	@$(MAKE_LIB)/stdlib-medium-smoke.sh

smoke-corpus: ensure-nyra
	@$(MAKE_LIB)/corpus-smoke.sh

smoke-examples: ensure-nyra
	@$(MAKE_LIB)/example-smoke.sh

smoke-serde-pkg: ensure-nyra
	@$(MAKE_LIB)/serde-pkg-smoke.sh

smoke-cross: ensure-nyra
	@$(MAKE_LIB)/cross-smoke.sh

smoke-sonic: ensure-nyra
	@$(MAKE_LIB)/sonic-check.sh

smoke-enterprise: smoke-sonic

smoke-vscode-extension:
	$(call log_step,vscode extension compile)
	@cd $(ROOT)/extensions/nyra && npm install --silent && npm run compile
	$(call log_ok,vscode extension compile)

# Nyra run/test smoke steps from the legacy test-all.sh.
test-runtime-smoke: ensure-nyra
	$(call log_step,runtime smoke examples and tests)
	@$(NYRA_BIN) run examples/syntax/hello.ny
	@$(NYRA_BIN) run examples/syntax/for_in.ny
	@$(NYRA_BIN) run examples/syntax/string_methods.ny
	@$(NYRA_BIN) run examples/syntax/date_basics.ny
	@$(NYRA_BIN) run examples/syntax/array_sort.ny
	@test "$$($(NYRA_BIN) run examples/syntax/math.ny)" = "30"
	@$(NYRA_BIN) run examples/syntax/hashmap_chain.ny
	@$(NYRA_BIN) run tests/nyra/net/gaps_fix_test.ny
	@$(NYRA_BIN) run tests/nyra/net/map_drop_test.ny
	@$(NYRA_BIN) run tests/nyra/net/net_prod_test.ny
	@$(NYRA_BIN) run tests/nyra/net/net_prod_test.typed.ny
	@$(NYRA_BIN) run tests/nyra/language_gaps.ny
	@$(NYRA_BIN) run tests/nyra/language_gaps.typed.ny
	@$(NYRA_BIN) test tests/nyra/match_or_test.ny
	@$(NYRA_BIN) run tests/nyra/match_or_test.typed.ny
	@$(NYRA_BIN) test tests/nyra/match_nested_test.ny
	@$(NYRA_BIN) run tests/nyra/match_nested_test.typed.ny
	@$(NYRA_BIN) test tests/nyra/match_struct_tuple_test.ny
	@$(NYRA_BIN) run tests/nyra/match_struct_tuple_test.typed.ny
	@$(NYRA_BIN) run tests/nyra/modules_test.ny
	@$(NYRA_BIN) run tests/nyra/modules_test.typed.ny
	@$(NYRA_BIN) run tests/nyra/stdlib_gaps.ny
	@$(NYRA_BIN) run tests/nyra/stdlib_gaps.typed.ny
	@$(NYRA_BIN) run tests/nyra/games_stdlib.ny
	@$(NYRA_BIN) run tests/nyra/games_stdlib.typed.ny
	@$(NYRA_BIN) run tests/nyra/games_gaps.ny
	@$(NYRA_BIN) run examples/dev/compiler_inprocess.ny
	@$(NYRA_BIN) test tests/nyra/parser_gaps_test.ny
	@$(NYRA_BIN) test tests/nyra/parser_gaps.typed.ny
	@$(NYRA_BIN) build examples/projects/calculator
	@$(NYRA_BIN) test examples/smoke_test_test.ny
	$(call log_ok,runtime smoke examples and tests)

smoke-cross-wasm: ensure-nyra
	@. $(MAKE_LIB)/wasm-toolchain.sh; \
	if wasm_toolchain_ready; then \
		$(NYRA_BIN) build $(ROOT)/examples/syntax/hello.ny --for wasm -o hello.wasm; \
		wasm_bin="$$(cd $(ROOT)/examples/syntax && pwd)/target/wasm32-wasip1/debug/hello.wasm"; \
		test -f "$$wasm_bin"; \
		if command -v wasmtime >/dev/null 2>&1; then wasmtime "$$wasm_bin"; \
		else printf 'make: note: wasmtime not installed; skipping wasm run\n'; fi; \
	else printf 'make: %s\n' "$$(wasm_toolchain_hint)"; \
	fi

smoke-cross-linux: ensure-nyra
	@if [ -n "$(NYRA_CROSS_LINUX)" ]; then \
		$(NYRA_BIN) build $(ROOT)/examples/syntax/hello.ny --release --for linux; \
		hello="$(ROOT)/examples/syntax"; \
		test -f "$$hello/target/x86_64-unknown-linux-gnu/release/hello" \
		  || test -f "$$hello/target/aarch64-unknown-linux-gnu/release/hello"; \
	else printf 'make: note: set NYRA_CROSS_LINUX=1 to test linux cross-compile\n'; \
	fi

smoke-cross-windows: ensure-nyra
	@if [ -n "$(NYRA_CROSS_WINDOWS)" ]; then \
		$(NYRA_BIN) build $(ROOT)/examples/syntax/hello.ny --for windows -o hello_win.exe; \
		hello="$(ROOT)/examples/syntax"; \
		test -f "$$hello/target/x86_64-pc-windows-gnu/debug/hello_win.exe" \
		  || test -f "$$hello/target/aarch64-pc-windows-gnu/debug/hello_win.exe"; \
	else printf 'make: note: set NYRA_CROSS_WINDOWS=1 with mingw-w64 to test windows cross-compile\n'; \
	fi
