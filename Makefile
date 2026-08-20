KVERSION ?= $(shell uname -r)
KERNEL_DIR ?= /lib/modules/$(KVERSION)/build
PWD := $(shell pwd)
KERNEL_SRC ?= $(PWD)/linux-src

# Tell the kernel build system to descend into the mac80211 directory
obj-m := mac80211/

all:
	@echo "Copying mac80211 source..."
	cp -r $(KERNEL_SRC)/net/mac80211 $(PWD)/

	@echo "Applying patch..."
	cd mac80211 && patch -p1 -N < ../patch-mlme.patch || true

	@echo "Building module..."
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) CONFIG_MAC80211=m modules

clean:
	@echo "Cleaning build artifacts..."
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) clean
	rm -rf mac80211
