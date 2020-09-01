
################################################################################
# Project settings

# Project name
NAME	= zturn

# Board name for all board specific fils in the boards folder
BOARD 	= zturn-7010

# Path to the vivado project
XPR		= $$HOME/git/zynq-sandbox/fpga/hlx/build/projects/zturn-lcd-vdma.xpr

# Path to the hlx bitstream if exists
# BIT		= 
BIT		= $$HOME/git/zynq-sandbox/fpga/hlx/build/projects/zturn-lcd-vdma.runs/impl_1/system_wrapper.bit

# Processor to use for FSBL
PROC 	= ps7_cortexa9_0

# uboot version
# Choos from the releases on https://github.com/Xilinx/u-boot-xlnx/releases
UBOOT_TAG = xilinx-v2020.1

# How many cores to use during compile
NPROC 	= $(shell nproc 2> /dev/null || echo 1)
# NPROC 	= 1

################################################################################
# FSBL settings
FBSL_CFLGAS	= -DFSBL_DEBUG_INFO

################################################################################
# uboot settings
UBOOT_CFLAGS = -DDEBUG

################################################################################
# UBOOT settings

# for boot.bin
UBOOT_LOAD		= 0x100000
UBOOT_STARTUP	= 0x100000

################################################################################
# Executables
RM 		= rm -rf
VIVADO 	= vivado -nolog -nojournal -mode batch
XSCT 	= xsct
TEST 	= echo main

################################################################################
# Output files
XSA   		= build/$(NAME).xsa
PS7INIT_TCL	= build/ps7_init.tcl
FSBL_PROJ	= build/$(NAME).fsbl
FSBL   		= build/$(NAME).fsbl/executable.elf
BOOTBIN 	= build/$(NAME).boot/boot.bin
BOOTBIF 	= build/$(NAME).boot/boot.bif
UBOOT 		= build/$(NAME).uboot/u-boot.bin
UBOOT_ELF	= build/$(NAME).uboot/u-boot.elf
UBOOT_SCR	= build/$(NAME).uboot/boot.scr
UBOOT_UENV	= build/$(NAME).uboot/uEnv.txt

################################################################################
# Errors
$(XPR):
	$(error Vivado HLx project not found.)

################################################################################
# Include board specifig variables
include boards/$(BOARD)/board.make

################################################################################
# XSA and FSBL
FSBL_DIR = fsbl
include $(FSBL_DIR)/fsbl.make
xsa: $(XSA)
fsbl-proj: $(FSBL_PROJ)
fsbl: $(FSBL)

################################################################################
# uboot bootloader
UBOOT_DIR = uboot
include $(UBOOT_DIR)/uboot.make
# uboot: $(UBOOT)

################################################################################
# BOOT binay
BOOTBIN_DIR = bootbin
include $(BOOTBIN_DIR)/bootbin.make
bootbin: $(BOOTBIN)
bootbif: $(BOOTBIF)


################################################################################
# JTAG utilities
run-fsbl: $(FSBL) $(PS7INIT_TCL)
	$(XSCT) scripts/jtag_run_elf.tcl $(FSBL)
run-uboot: $(UBOOT_ELF) $(PS7INIT_TCL)
	$(XSCT) scripts/jtag_run_elf.tcl $(UBOOT_ELF)