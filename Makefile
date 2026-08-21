KVERSION ?= $(shell uname -r)
KERNEL_DIR ?= /lib/modules/$(KVERSION)/build
PWD := $(shell pwd)

obj-m := mac80211/

all: prepare_source
	@echo "Building module..."
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) CONFIG_MAC80211=m modules

prepare_source:
	@if [ ! -d "mac80211" ]; then \
		TARBALL=$$(ls /usr/src/linux-source-*.tar.bz2 2>/dev/null | head -n 1); \
		if [ -n "$$TARBALL" ]; then \
			echo "Extracting only net/mac80211 from $$TARBALL..."; \
			tar -xjf "$$TARBALL" -C $(PWD) --strip-components=2 --wildcards '*/net/mac80211'; \
			echo "Applying patch..."; \
			cd mac80211 && patch -p1 -N < ../patch-mlme.patch || true; \
		else \
			echo "ERROR: Kernel source tarball not found in /usr/src/."; \
			exit 1; \
		fi \
	fi

clean:
	@echo "Cleaning build artifacts..."
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) clean
	rm -rf mac80211
