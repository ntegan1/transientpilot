# Virtualized openpilot Setup
This page will describe how to easily utilize an automated process for setting up an openpilot installation inside a Qemu Arch Linux virtual machine, with 3d graphics acceleration.

## work in progress
need to finalize and upload the scripts i've made for running the transient virtual machine, and the script to run inside vm for automated openpilot installation/setup.

## Requirements
#### Operating System
This setup was tested on arch linux and ubuntu.
#### Transient
[Transient](https://github.com/alschwalm/transient) allows for easy setup of persistent Qemu virtual machines based on pre-made disk images from the Vagrant Cloud.  
###### Install
`pip3 install transient`  
#### Qemu
###### Install (ubuntu)
`sudo apt install qemu-system`
#### Virgl
Allows for using host gpu for graphics acceleration via opengl somehow.  
There is some previous work for 
###### Install (ubuntu)
`sudo apt install libvirglrenderer1 virgl-server`
#### sftp-server
for sharing data directory
###### Install (ubuntu)
`sudo apt install openssh-sftp-server`

## Videos
TODO: no embed in wiki pages?
#### Brief overview of setup script and transient vm script

https://user-images.githubusercontent.com/3820605/206734550-b3c3ec3a-34f6-41a0-8ab6-b77a6fd47c65.mp4



#### Example of using for plotjuggler, replay, and ui.

https://user-images.githubusercontent.com/3820605/206734571-933a4adb-b4e6-4062-ac6e-dafa348c6515.mp4



