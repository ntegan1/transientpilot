
.PHONY: all clean cleaner run test

## User Config
# all modifications when vm is running will be saved under this name
VM_NAME = named


# Not meant to be configured maybe
ROOT = $(CURDIR)
VM_DIR = $(CURDIR)/vm
VM_IMAGE_DIR = $(VM_DIR)/image
VM_STORE_DIR = $(VM_DIR)/vmstore
# backend / base image
VM_IMAGE_NAME = archlinuxpilot
VM_IMAGE_FILE = $(VM_IMAGE_DIR)/$(VM_IMAGE_NAME).qcow2
VM_IMAGE_FILE_BASE = $(shell basename $(VM_IMAGE_FILE))
VM_IMAGE_WORKING_FILE = $(VM_IMAGE_DIR)/$(VM_IMAGE_NAME).working
# what is this dir
VM_IMAGE_WORKING_DIR = $(VM_IMAGE_DIR)/.working
TRANSIENT_ARGS_COMMON := \
		--verbose \
		--name $(VM_NAME) \
		--image-backend $(VM_IMAGE_DIR) \
		--vmstore $(VM_STORE_DIR)



all: $(VM_IMAGE_FILE)


$(VM_IMAGE_FILE):
	(transient image build --verbose --local \
		--name $(VM_IMAGE_NAME) $(VM_IMAGE_DIR))

cleancmd = $(RM) $(VM_IMAGE_FILE) $(VM_IMAGE_WORKING_FILE) $(VM_IMAGE_WORKING_DIR)
clean:
	-@echo $(cleancmd)
cleaner:
	$(cleancmd)


run: all
	(transient run \
		$(TRANSIENT_ARGS_COMMON) \
		$(VM_IMAGE_FILE_BASE) \
		)

test:
	true
# see if virglrenderer installed,
# see if qemu has virglrenderer




