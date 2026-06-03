PACKAGES := hypr waybar
TARGET := $(HOME)
STOW := stow

.PHONY: install remove dry-run restow

install:
	$(STOW) -t $(TARGET) $(PACKAGES)

remove:
	$(STOW) -D -t $(TARGET) $(PACKAGES)

dry-run:
	$(STOW) -n -v -t $(TARGET) $(PACKAGES)

restow:
	$(STOW) -R -t $(TARGET) $(PACKAGES)
