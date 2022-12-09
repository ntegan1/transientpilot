
.PHONY: all clean cleaner run test

## User Config
# all modifications when vm is running will be saved under this name
VM_NAME = named
VM_MEMORY = 3G
VM_CPU_THREADS = 3
VM_DISPLAY_XRES = 1280
VM_DISPLAY_YRES = 720


## Not meant to be configured maybe
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

## Transient VM Arguments
TRANSIENT_ARGS_COMMON := \
		--verbose \
		--name $(VM_NAME) \
		--image-backend $(VM_IMAGE_DIR) \
		--vmstore $(VM_STORE_DIR)
TRANSIENT_SSH_ARGS := \
  	--ssh-console \
  	--ssh-port 2000
#TRANSIENT_SSH_PORT_FORWARD_ARGS := \
#		--ssh-option "AddressFamily inet" \
#		--ssh-option "LocalForward 3000 127.0.0.1:3000" \
#		--ssh-option "LocalForward 3001 127.0.0.1:3001"
TRANSIENT_QEMU_MACHINE_ARGS := \
		-chardev socket,path=/tmp/qga.sock,server=on,wait=off,id=qga \
		-device virtio-serial \
		-device virtserialport,chardev=qga,name=org.qemu.guest_agent.0 \
		-device virtio-vga-gl,max_outputs=1,xres=$(VM_DISPLAY_XRES),yres=$(VM_DISPLAY_YRES) \
		-machine q35,accel=kvm \
		-m $(VM_MEMORY) -smp $(VM_CPU_THREADS) -display sdl,gl=on



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
		$(TRANSIENT_SSH_ARGS) \
		$(VM_IMAGE_FILE_BASE) \
		-- \
		$(TRANSIENT_QEMU_MACHINE_ARGS) \
		)

test:
	# see if qemu has virglrenderer
	(set -e; \
	 qemu-system-x86_64 -device help | grep -q virtio-vga-gl; \
	)
	# see if virglrenderer installed,




