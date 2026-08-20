KVERSION ?= $(shell uname -r)
KERNEL_DIR ?= /lib/modules/$(KVERSION)/build
PWD := $(shell pwd)
# Unpack into /tmp to avoid permission issues for non-root users
KERNEL_SRC := /tmp/linux-src-$(KVERSION)

obj-m := mac80211/

all: prepare_source
	@echo "Building module..."
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) CONFIG_MAC80211=m modules

prepare_source: ensure_source
	@if [ ! -d "mac80211" ]; then \
		echo "Copying mac80211 source from $(KERNEL_SRC)..."; \
		cp -r $(KERNEL_SRC)/net/mac80211 $(PWD)/; \
		echo "Applying patch..."; \
		cd mac80211 && patch -p1 -N < ../patch-mlme.patch || true; \
	fi

ensure_source:
	@if [ ! -f "$(KERNEL_SRC)/Makefile" ]; then \
		TARBALL=$$(ls /usr/src/linux-source-*.tar.bz2 2>/dev/null | head -n 1); \
		if [ -n "$$TARBALL" ]; then \
			echo "Extracting $$TARBALL to $(KERNEL_SRC)..."; \
			mkdir -p $(KERNEL_SRC); \
			tar -xjf "$$TARBALL" -C $(KERNEL_SRC) --strip-components=1; \
		else \
			echo "ERROR: Kernel source tarball not found in /usr/src/."; \
			exit 1; \
		fi \
	fi

clean:
	@echo "Cleaning build artifacts..."
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) clean
	rm -rf mac80211
