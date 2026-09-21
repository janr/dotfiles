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
MIC_PEDAL_UDEV_RULE := udev/70-mic-pedal.rules
UDEV_RULES_DIR := /etc/udev/rules.d

.PHONY: install install-ubuntu install-cachyos install-mic-pedal install-mic-pedal-udev remove remove-cachyos dry-run dry-run-ubuntu dry-run-cachyos restow

install:
	$(if $(filter cachyos,$(OS_ID)),mkdir -p $(SYSTEMD_USER_DIR))
	$(STOW) -t $(TARGET) $(PACKAGES)
	$(if $(filter cachyos,$(OS_ID)),$(SYSTEMCTL_USER) daemon-reload)
	$(if $(filter cachyos,$(OS_ID)),$(SYSTEMCTL_USER) enable --now focal-keepalive.timer)
	$(if $(filter cachyos,$(OS_ID)),$(SYSTEMCTL_USER) enable --now mic-pedal.service)

install-ubuntu:
	$(STOW) -t $(TARGET) $(UBUNTU_PACKAGES)

install-cachyos:
	mkdir -p $(SYSTEMD_USER_DIR)
	$(STOW) -t $(TARGET) $(CACHYOS_PACKAGES)
	$(SYSTEMCTL_USER) daemon-reload
	$(SYSTEMCTL_USER) enable --now focal-keepalive.timer
	$(SYSTEMCTL_USER) enable --now mic-pedal.service

install-mic-pedal: install-mic-pedal-udev
	sudo pacman -S --needed python-evdev libnotify
	mkdir -p $(SYSTEMD_USER_DIR)
	$(STOW) -R -t $(TARGET) bin hypr-cachyos
	$(SYSTEMCTL_USER) daemon-reload
	$(SYSTEMCTL_USER) enable --now mic-pedal.service

install-mic-pedal-udev:
	udevadm verify $(MIC_PEDAL_UDEV_RULE)
	sudo install -m 0644 $(MIC_PEDAL_UDEV_RULE) $(UDEV_RULES_DIR)/70-mic-pedal.rules
	sudo udevadm control --reload-rules
	@printf '%s\n' 'Installed only the mic-pedal udev rule.'
	@printf '%s\n' 'Run "make install-mic-pedal" for dependencies, Stow links, and the service.'
	@printf '%s\n' 'Unplug and reconnect the footswitch to apply the new rule.'

remove:
	$(if $(filter cachyos,$(OS_ID)),-$(SYSTEMCTL_USER) disable --now mic-pedal.service)
	$(if $(filter cachyos,$(OS_ID)),-$(SYSTEMCTL_USER) disable --now focal-keepalive.timer)
	$(STOW) -D -t $(TARGET) $(PACKAGES)
	$(if $(filter cachyos,$(OS_ID)),$(SYSTEMCTL_USER) daemon-reload)

remove-cachyos:
	-$(SYSTEMCTL_USER) disable --now mic-pedal.service
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
