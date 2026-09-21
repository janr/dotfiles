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
RMAPI_VERSION := v0.0.35
RMAPI_DIR := $(TARGET)/.local/share/remarkable-push/bin
RMAPI := $(RMAPI_DIR)/rmapi

.PHONY: install install-ubuntu install-cachyos install-mic-pedal install-mic-pedal-udev remove remove-cachyos dry-run dry-run-ubuntu dry-run-cachyos restow setup-remarkable remarkable-auth remove-remarkable

install: setup-remarkable
	$(if $(filter cachyos,$(OS_ID)),mkdir -p $(SYSTEMD_USER_DIR))
	$(STOW) -t $(TARGET) $(PACKAGES)
	$(if $(filter cachyos,$(OS_ID)),$(SYSTEMCTL_USER) daemon-reload)
	$(if $(filter cachyos,$(OS_ID)),$(SYSTEMCTL_USER) enable --now focal-keepalive.timer)
	$(if $(filter cachyos,$(OS_ID)),$(SYSTEMCTL_USER) enable --now mic-pedal.service)

install-ubuntu: setup-remarkable
	$(STOW) -t $(TARGET) $(UBUNTU_PACKAGES)

install-cachyos: setup-remarkable
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

# rmapi is a Go executable, not a Python package, so keep it in an isolated
# application directory rather than a virtualenv. The release archive is
# pinned and checksum-verified.
setup-remarkable:
	@set -eu; \
	case "$$(uname -m)" in \
		x86_64) arch=amd64; sha=117616151d11937446ead6972b0934f97155443087f8406141db38fd1ac8fb25 ;; \
		aarch64|arm64) arch=arm64; sha=645c170d8119b4dcb652cf79612e362fcb032dc0e5869ff520eec1324da39637 ;; \
		*) echo "Unsupported rmapi architecture: $$(uname -m)" >&2; exit 1 ;; \
	esac; \
	if [ -x "$(RMAPI)" ] && [ "$$(cat "$(RMAPI_DIR)/.version" 2>/dev/null || true)" = "$(RMAPI_VERSION)" ]; then \
		echo "rmapi $(RMAPI_VERSION) is already installed in $(RMAPI_DIR)"; \
		exit 0; \
	fi; \
	tmp=$$(mktemp -d); trap 'rm -rf "$$tmp"' EXIT; \
	curl -fL --retry 2 -o "$$tmp/rmapi.tar.gz" \
		"https://github.com/ddvk/rmapi/releases/download/$(RMAPI_VERSION)/rmapi-linux-$$arch.tar.gz"; \
	printf '%s  %s\n' "$$sha" "$$tmp/rmapi.tar.gz" | sha256sum --check --status; \
	mkdir -p "$(RMAPI_DIR)"; \
	tar -xzf "$$tmp/rmapi.tar.gz" -C "$(RMAPI_DIR)" rmapi; \
	chmod 0755 "$(RMAPI)"; \
	printf '%s\n' "$(RMAPI_VERSION)" > "$(RMAPI_DIR)/.version"; \
	echo "Installed rmapi $(RMAPI_VERSION) in $(RMAPI_DIR)"

remarkable-auth: setup-remarkable
	$(RMAPI) ls

remove-remarkable:
	rm -rf "$(TARGET)/.local/share/remarkable-push"

restow:
	$(STOW) -R -t $(TARGET) $(PACKAGES)
	$(if $(filter cachyos,$(OS_ID)),$(SYSTEMCTL_USER) daemon-reload)
