COMMON_PACKAGES := bash bin kitty nvim share
UBUNTU_PACKAGES := $(COMMON_PACKAGES) hypr waybar
# CachyOS supplies its own Zsh/Fish defaults. Manage the Bash login shell,
# Kitty, Noctalia, and the Hyprland overlay here.
CACHYOS_PACKAGES := bash bin kitty nvim share hypr hypr-cachyos noctalia
OS_ID := $(shell . /etc/os-release 2>/dev/null && printf '%s' "$$ID")

ifeq ($(OS_ID),cachyos)
PACKAGES := $(CACHYOS_PACKAGES)
else
PACKAGES := $(UBUNTU_PACKAGES)
endif
TARGET := $(HOME)
STOW := stow

.PHONY: install install-ubuntu install-cachyos remove remove-cachyos dry-run dry-run-ubuntu dry-run-cachyos restow

install:
	$(STOW) -t $(TARGET) $(PACKAGES)

install-ubuntu:
	$(STOW) -t $(TARGET) $(UBUNTU_PACKAGES)

install-cachyos:
	$(STOW) -t $(TARGET) $(CACHYOS_PACKAGES)

remove:
	$(STOW) -D -t $(TARGET) $(PACKAGES)

remove-cachyos:
	$(STOW) -D -t $(TARGET) $(CACHYOS_PACKAGES)

dry-run:
	$(STOW) -n -v -t $(TARGET) $(PACKAGES)

dry-run-ubuntu:
	$(STOW) -n -v -t $(TARGET) $(UBUNTU_PACKAGES)

dry-run-cachyos:
	$(STOW) -n -v -t $(TARGET) $(CACHYOS_PACKAGES)

restow:
	$(STOW) -R -t $(TARGET) $(PACKAGES)
