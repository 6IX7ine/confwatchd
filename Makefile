.PHONY: build fmt lint run test vet deps install

SRC_PATH=.
TARGET=confwatchd
PREFIX_DIR=/usr/local
BIN_DIR=$(PREFIX_DIR)/bin
CONFIG_DIR=$(PREFIX_DIR)/etc
WEBAPP_DIR=$(PREFIX_DIR)/share
SERVICE_DIR=/lib/systemd/system
SERVICE_LN_DIR=/etc/systemd/system

default: build

build: deps fmt vet lint 
	@go build $(FLAGS) -o $(TARGET) $(SRC_PATH)

vet:
	@go vet $(SRC_PATH)

fmt:
	@go fmt $(SRC_PATH)/...

lint:
	@golint $(SRC_PATH)

test:
	@go test $(SRC_PATH)/...

clean:
	@rm -rf $(TARGET)

deps:
	@go get github.com/gin-gonic/gin
	@go get gopkg.in/unrolled/secure.v1
	@go get github.com/gin-gonic/autotls
	@go get github.com/michelloworld/ez-gin-template

# runs on previlege
install: build
	@echo "Installing $(TARGET) in $(PREFIX_DIR)"
	@install -D -m 744 (SRC_PATH)/$(TARGET) $(BIN_DIR)/$(TARGET)
	@setcap 'cap_net_bind_service=+ep' $(BIN_DIR)/$(TARGET)
	@cp -r ../arc $(WEBAPP_DIR)/arc
	@install -D -m 644 $(SRC_PATH)/sample_config.json $(CONFIG_DIR)/$(TARGET)/config.json
	@install -D -m 644 $(SRC_PATH)/arcd@.service $(SERVICE_DIR)/arcd@.service
	@ln -s $(SERVICE_DIR)/arcd@.service $(SERVICE_LN_DIR)/arcd@.service || echo "symlink already exists...skipping"
	@echo "Done."
