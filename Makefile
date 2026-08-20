KVERSION ?= $(shell uname -r)
KERNEL_DIR ?= /lib/modules/$(KVERSION)/build
PWD := $(shell pwd)

KERNEL_SRC ?= /tmp/linux-src-$(KVERSION)
ifeq ($(wildcard $(KERNEL_SRC)/Makefile),)
    KERNEL_SRC := /usr/src/linux-src
endif
ifeq ($(wildcard $(KERNEL_SRC)/Makefile),)
    KERNEL_SRC := $(shell ls -d /usr/src/linux-source-* 2>/dev/null | head -n 1)
endif

ifneq ($(MAKECMDGOALS),clean)
ifeq ($(wildcard $(PWD)/mac80211/Makefile),)
    $(info [DKMS Hook] Fetching mac80211 from $(KERNEL_SRC)...)
    _copy_hook := $(shell cp -r $(KERNEL_SRC)/net/mac80211 $(PWD)/)

    $(info [DKMS Hook] Applying patch-mlme.patch...)
    # Dummy assignment prevents stdout from breaking Makefile syntax
    _patch_hook := $(shell cd $(PWD)/mac80211 && patch -p1 -N < ../patch-mlme.patch || true)
endif
endif

obj-m := mac80211/

all: ensure_source
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) CONFIG_MAC80211=m modules

ensure_source:
	@if [ ! -f "$(KERNEL_SRC)/Makefile" ]; then \
		TARBALL=$$(ls /usr/src/linux-source-*.tar.* 2>/dev/null | head -n 1); \
		if [ -n "$$TARBALL" ]; then \
			echo "Extracting kernel source from $$TARBALL to /tmp/linux-src-$(KVERSION)..."; \
			mkdir -p /tmp/linux-src-$(KVERSION); \
			tar -xf "$$TARBALL" -C /tmp/linux-src-$(KVERSION) --strip-components=1; \
		else \
			echo "ERROR: Kernel source not found. Install 'linux-source'."; \
			exit 1; \
		fi \
	fi

clean:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) clean
	rm -rf $(PWD)/mac80211
