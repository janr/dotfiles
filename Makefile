COMMON_PACKAGES := bash bin kitty nvim share
UBUNTU_PACKAGES := $(COMMON_PACKAGES) hypr waybar
CACHYOS_PACKAGES := $(COMMON_PACKAGES) hypr hypr-cachyos
PACKAGES := $(UBUNTU_PACKAGES)
TARGET := $(HOME)
STOW := stow

.PHONY: install install-ubuntu install-cachyos remove remove-cachyos dry-run restow

install:
	$(MAKE) install-ubuntu

install-ubuntu:
	$(STOW) -t $(TARGET) $(PACKAGES)

install-cachyos:
	$(STOW) -t $(TARGET) $(CACHYOS_PACKAGES)

remove:
	$(STOW) -D -t $(TARGET) $(PACKAGES)

remove-cachyos:
	$(STOW) -D -t $(TARGET) $(CACHYOS_PACKAGES)

dry-run:
	$(STOW) -n -v -t $(TARGET) $(PACKAGES)

restow:
	$(STOW) -R -t $(TARGET) $(PACKAGES)
