export FEOSSDK := $(CURDIR)/FeOS/sdk
export FEOSDEST :=

.PHONY: all clean ALL

all: ALL

clean:
	@rm -rf FeOS FeOS-SDK feos.fpkg FeOS-SDK.tar.bz2

############## STAGE 1 ##############
ifeq ($(strip $(STAGE)),)

.PHONY: FeOS-build

ALL: FeOS-build
	@STAGE=2 $(MAKE) --no-print-directory

FeOS-build: FeOS
	@echo "Building FeOS - Temporary SDK at $(FEOSSDK)"
	@echo
	@$(MAKE) --no-print-directory -C FeOS install

FeOS:
	@echo FeOS directory does not exist, cloning repository...
	@git clone git://github.com/mtheall/FeOS.git

else
############## STAGE 2 ##############

USERLIBS := $(patsubst FeOS/sdk/userlib/%,%,$(shell find FeOS/sdk/userlib/ -maxdepth 1 -type d))

.PHONY: FeOS-SDK feos.fpkg $(USERLIBS)

ALL: FeOS-SDK.tar.bz2
	@echo "Done!"

feos.fpkg:
	@echo "Packaging FeOS..."
	@FeOS/sdk/bin/fartool FeOS/FeOS ?stdout | gzip -c9 | FeOS/sdk/bin/fpkgtool feos.manifest $@

FeOS-SDK:
	@echo "Preparing base FeOS SDK..."
	@rm -rf FeOS-SDK FeOS-SDK.tar.bz2
	@mkdir -p FeOS-SDK/bin FeOS-SDK/examples FeOS-SDK/include FeOS-SDK/lib FeOS-SDK/mk FeOS-SDK/templates FeOS-SDK/userlib
	@cp $(shell find FeOS/sdk/bin -maxdepth 1 -type f) FeOS-SDK/bin/
	@cp -r FeOS/sdk/examples/* FeOS-SDK/examples/
	@cp -r FeOS/sdk/include/* FeOS-SDK/include/
	@cp -r FeOS/sdk/lib/* FeOS-SDK/lib/
	@cp -r FeOS/sdk/mk/* FeOS-SDK/mk/
	@cp -r FeOS/sdk/templates/* FeOS-SDK/templates/
	@cp $(shell find FeOS/sdk/userlib -maxdepth 1 -type f) FeOS-SDK/userlib/
	@cp FeOS/COPYING FeOS-SDK/

$(USERLIBS):
	@echo "Bundling $@..."
	@mkdir -p FeOS-SDK/userlib/$@/include FeOS-SDK/userlib/$@/lib
	@cp -r FeOS/sdk/userlib/$@/include/* FeOS-SDK/userlib/$@/include/
	@cp -r FeOS/sdk/userlib/$@/lib/* FeOS-SDK/userlib/$@/lib/

FeOS-SDK.tar.bz2: feos.fpkg FeOS-SDK $(USERLIBS)
	@echo Compressing SDK...
	@tar -cjf FeOS-SDK.tar.bz2 FeOS-SDK

endif
