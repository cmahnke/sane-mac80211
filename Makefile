KVERSION ?= $(shell uname -r)
KERNEL_DIR ?= /lib/modules/$(KVERSION)/build
PWD := $(shell pwd)

KERNEL_SRC ?= $(PWD)/linux-src
ifeq ($(wildcard $(KERNEL_SRC)/Makefile),)
    KERNEL_SRC := /usr/src/linux-src
endif
ifeq ($(wildcard $(KERNEL_SRC)/Makefile),)
    KERNEL_SRC := $(shell ls -d /usr/src/linux-source-* 2>/dev/null | head -n 1)
endif

obj-m := mac80211/


all: ensure_source
	@echo "Copying mac80211 source from $(KERNEL_SRC)..."
	@rm -rf mac80211
	@cp -r $(KERNEL_SRC)/net/mac80211 $(PWD)/

	@echo "Applying patch..."
	@cd mac80211 && patch -p1 -N < ../patch-mlme.patch || true

	@echo "Building module..."
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) CONFIG_MAC80211=m modules

ensure_source:
	@if [ ! -f "$(KERNEL_SRC)/Makefile" ]; then \
		TARBALL=$$(ls /usr/src/linux-source-*.tar.* 2>/dev/null | head -n 1); \
		if [ -n "$$TARBALL" ]; then \
			echo "Extracting kernel source from $$TARBALL..."; \
			tar -xf "$$TARBALL" -C /usr/src; \
			for dir in /usr/src/linux-source-*; do \
				if [ -d "$$dir" ] && [ ! -L "$$dir" ]; then \
					mv "$$dir" /usr/src/linux-src; \
					break; \
				fi \
			done; \
		else \
			echo "ERROR: Kernel source not found. Please ensure 'linux-source' is installed."; \
			exit 1; \
		fi \
	fi

clean:
	@echo "Cleaning build artifacts..."
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) clean
	rm -rf mac80211
