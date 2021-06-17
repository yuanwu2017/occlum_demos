LIB_PATH := lib
BIN_PATH := bin
OBJ_PATH := obj
SRC_PATH := src
INC_PATH := include
SGX_SDK_INC_PATH := /opt/intel/sgxsdk/include

CC := gcc

TARGET_NAME := dcap_demo
TARGET := $(BIN_PATH)/$(TARGET_NAME)

SRC := $(foreach x, $(SRC_PATH), $(wildcard $(addprefix $(x)/*,.c*)))
OBJ := $(addprefix $(OBJ_PATH)/, $(addsuffix .o, $(notdir $(basename $(SRC)))))

CLEAN_LIST := $(BIN_PATH)  $(OBJ_PATH) libmbedcrypto.* libmbedtls.* libmbedx509.*

############################# MBEDTLS DEPENDENCY ##############################
MBEDTLS_VERSION ?= 2.21.0
MBEDTLS_SRC ?= mbedtls-$(MBEDTLS_VERSION).tar.gz
MBEDTLS_URI ?= \
	https://github.com/ARMmbed/mbedtls/archive \
	https://packages.grapheneproject.io/distfiles
MBEDTLS_CHECKSUM ?= 320e930b7596ade650ae4fc9ba94b510d05e3a7d63520e121d8fdc7a21602db9

# mbedTLS uses a submodule mbedcrypto, need to download it and move under mbedtls/crypto
MBEDCRYPTO_VERSION ?= 3.1.0
MBEDCRYPTO_SRC ?= mbedcrypto-$(MBEDCRYPTO_VERSION).tar.gz
MBEDCRYPTO_URI ?= \
	https://github.com/ARMmbed/mbed-crypto/archive \
	https://packages.grapheneproject.io/distfiles
MBEDCRYPTO_CHECKSUM ?= 7e171df03560031bc712489930831e70ae4b70ff521a609c6361f36bd5f8b76b


CCFLAGS := -I$(INC_PATH) -I$(SGX_SDK_INC_PATH) -I./mbedtls/install/include/ -I./mbedtls/crypto/include
CCOBJFLAGS := $(CCFLAGS) -c
#LFLAGS :=  -Wl,-rpath,./lib/ -L./lib/ -lmbedcrypto -lmbedtls -lmbedx509
mbedtls_libs := $(LIB_PATH)/libmbedcrypto.so $(LIB_PATH)/libmbedtls.so $(LIB_PATH)/libmbedx509.so
mbedtls_obj := libmbedcrypto.so libmbedtls.so libmbedx509.so

.PHONY: all mkdir clean

default: mkdir all

mkdir:
	@mkdir -p $(BIN_PATH) $(OBJ_PATH) $(LIB_PATH)

all: $(TARGET)

$(TARGET): $(OBJ) 
	$(CC) $(CCFLAGS) $(LFLAGS) -o $@ $(OBJ) $(mbedtls_obj)

$(OBJ): $(mbedtls_obj)

$(OBJ_PATH)/%.o: $(SRC_PATH)/%.c*
	$(CC) $(CCOBJFLAGS) -o $@ $< 

$(MBEDTLS_SRC):
	./download --output ./$@ $(foreach mirror,$(MBEDTLS_URI),--url $(mirror)/$(MBEDTLS_SRC)) --sha256 $(MBEDTLS_CHECKSUM)

$(MBEDCRYPTO_SRC):
	./download --output ./$@ $(foreach mirror,$(MBEDCRYPTO_URI),--url $(mirror)/$(MBEDCRYPTO_SRC)) --sha256 $(MBEDCRYPTO_CHECKSUM)

mbedtls/CMakeLists.txt: $(MBEDTLS_SRC) $(MBEDCRYPTO_SRC)
	tar --touch -xzf $(MBEDTLS_SRC) \
	&& tar --touch -xzf $(MBEDCRYPTO_SRC) \
	&& mv mbedtls-mbedtls-$(MBEDTLS_VERSION) mbedtls \
	&& $(RM) -r mbedtls/crypto \
	&& mv mbed-crypto-mbedcrypto-$(MBEDCRYPTO_VERSION) mbedtls \
	&& mv mbedtls/mbed-crypto-mbedcrypto-$(MBEDCRYPTO_VERSION) mbedtls/crypto \
	&& mkdir mbedtls/install \
	&& cd mbedtls && ./scripts/config.pl set MBEDTLS_CMAC_C && make SHARED=1 DESTDIR=install install .

########################### COPIES FOR CONVENIENCE ############################
libmbedcrypto.so: mbedtls/CMakeLists.txt
#	cp ./mbedtls/install/lib/$@.* $(LIB_PATH)/
#	ln -s $(LIB_PATH)/$@.* $(LIB_PATH)/$@
	cp ./mbedtls/install/lib/$@.* .
	ln -s $@.* $@

libmbedtls.so:mbedtls/CMakeLists.txt
#	cp ./mbedtls/install/lib/$@.* $(LIB_PATH)/
#	ln -s $(LIB_PATH)/$@.* $(LIB_PATH)/$@
	cp ./mbedtls/install/lib/$@.* .
	ln -s $@.* $@

libmbedx509.so:mbedtls/CMakeLists.txt
#	cp ./mbedtls/install/lib/$@.* $(LIB_PATH)/
#	ln -s $(LIB_PATH)/$@.* $(LIB_PATH)/$@
	cp ./mbedtls/install/lib/$@.* .
	ln -s $@.* $@




clean:
	@rm -rf $(CLEAN_LIST)
