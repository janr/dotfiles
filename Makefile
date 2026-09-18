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
SYSTEMCTL_USER := systemctl --user
SYSTEMD_USER_DIR := $(TARGET)/.config/systemd/user

.PHONY: install install-ubuntu install-cachyos remove remove-cachyos dry-run dry-run-ubuntu dry-run-cachyos restow

install:
	$(if $(filter cachyos,$(OS_ID)),mkdir -p $(SYSTEMD_USER_DIR))
	$(STOW) -t $(TARGET) $(PACKAGES)
	$(if $(filter cachyos,$(OS_ID)),$(SYSTEMCTL_USER) daemon-reload)
	$(if $(filter cachyos,$(OS_ID)),$(SYSTEMCTL_USER) enable --now focal-keepalive.timer)

install-ubuntu:
	$(STOW) -t $(TARGET) $(UBUNTU_PACKAGES)

install-cachyos:
	mkdir -p $(SYSTEMD_USER_DIR)
	$(STOW) -t $(TARGET) $(CACHYOS_PACKAGES)
	$(SYSTEMCTL_USER) daemon-reload
	$(SYSTEMCTL_USER) enable --now focal-keepalive.timer

remove:
	$(if $(filter cachyos,$(OS_ID)),-$(SYSTEMCTL_USER) disable --now focal-keepalive.timer)
	$(STOW) -D -t $(TARGET) $(PACKAGES)
	$(if $(filter cachyos,$(OS_ID)),$(SYSTEMCTL_USER) daemon-reload)

remove-cachyos:
	-$(SYSTEMCTL_USER) disable --now focal-keepalive.timer
	$(STOW) -D -t $(TARGET) $(CACHYOS_PACKAGES)
	$(SYSTEMCTL_USER) daemon-reload

dry-run:
	$(STOW) -n -v -t $(TARGET) $(PACKAGES)

dry-run-ubuntu:
	$(STOW) -n -v -t $(TARGET) $(UBUNTU_PACKAGES)

dry-run-cachyos:
	$(STOW) -n -v -t $(TARGET) $(CACHYOS_PACKAGES)

restow:
	$(STOW) -R -t $(TARGET) $(PACKAGES)
	$(if $(filter cachyos,$(OS_ID)),$(SYSTEMCTL_USER) daemon-reload)
