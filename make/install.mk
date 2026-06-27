# Install Nyra from release tarball or local development tree.

.PHONY: install-release install-llvm install-dev

install-release:
	@$(MAKE_LIB)/install.sh $(INSTALL_ARGS)

# Usage: make install-llvm INSTALL_LLVM_ARGS="--download --wasi"
install-llvm:
	@$(MAKE_LIB)/install-llvm-toolchain.sh $(INSTALL_LLVM_ARGS)

install-dev:
	@$(MAKE_LIB)/updateLang.sh

# Legacy alias
.PHONY: update-lang
update-lang: install-dev
