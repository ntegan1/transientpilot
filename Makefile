
.PHONY: all clean cleaner run test submodules



## User Config
# all modifications when vm is running will be saved under this name
VM_NAME = named
VM_MEMORY = 3G
VM_CPU_THREADS = 3
VM_DISPLAY_XRES = 1536
VM_DISPLAY_YRES = 864
#https://askubuntu.com/questions/377937/how-do-i-set-a-custom-resolution

$(shell git submodule update --init > /dev/null 2>&1)

## Not meant to be configured maybe
ROOT = $(CURDIR)
THIRD_PARTY_DIR = $(CURDIR)/thirdparty
SHARED_DATA_DIR = $(CURDIR)/data
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

		#--sftp-bin-name /usr/lib/ssh/sftp-server \
## Transient VM Arguments
TRANSIENT_ARGS_COMMON := \
		--verbose \
		--name $(VM_NAME) \
		--shared-folder $(SHARED_DATA_DIR):/home/vagrant/data \
		--image-backend $(VM_IMAGE_DIR) \
		--vmstore $(VM_STORE_DIR)
TRANSIENT_SSH_ARGS := \
  	--ssh-timeout 120 \
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
SUBMODULE_DWM_LINK = $(shell bash -c 'source $(THIRD_PARTY_DIR)/dwm/PKGBUILD && printf "%s\n" "$${source[@]}" | grep "^https"')
SUBMODULE_ST_LINK = $(shell bash -c 'source $(THIRD_PARTY_DIR)/st/PKGBUILD && printf "%s\n" "$${source[@]}" | grep "^https"')
SUBMODULE_DWM = $(THIRD_PARTY_DIR)/dwm
SUBMODULE_ST = $(THIRD_PARTY_DIR)/st
SUBMODULE_PRE_DOWNLOAD := \
		$(SUBMODULE_DWM)/$(shell basename $(SUBMODULE_DWM_LINK)) \
		$(SUBMODULE_ST)/$(shell basename $(SUBMODULE_ST_LINK))
SUBMODULES := \
		$(SUBMODULE_DWM)/.git \
		$(SUBMODULE_ST)/.git


# (source ./PKGBUILD && for f in ${source[@]}; do echo "$f" | grep -q '^https' && curl -L -O "$f"; done)


all: submodules $(VM_IMAGE_FILE)
$(SUBMODULES):
	git submodule update --init
$(SUBMODULE_PRE_DOWNLOAD): $(SUBMODULES)
	(cd $(SUBMODULE_DWM); curl -C - -L -O $(SUBMODULE_DWM_LINK))
	(cd $(SUBMODULE_ST); curl -C - -L -O $(SUBMODULE_ST_LINK))
submodules: $(SUBMODULES) $(SUBMODULE_PRE_DOWNLOAD)


$(VM_IMAGE_FILE):
	(transient image build --verbose --local \
		--name $(VM_IMAGE_NAME) $(VM_IMAGE_DIR))

cleancmd = $(RM) -r $(VM_IMAGE_FILE) $(VM_IMAGE_WORKING_FILE) $(VM_IMAGE_WORKING_DIR)
cleancmd2 = git submodule deinit -f --all
cleancmd3 = $(RM) -r $(VM_STORE_DIR)/*
clean:
	-@echo $(cleancmd)
	-@echo $(cleancmd2)
	-@echo $(cleancmd3)
cleaner:
	$(cleancmd)
	$(cleancmd2)
	$(cleancmd3)


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




