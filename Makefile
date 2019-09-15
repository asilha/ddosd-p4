PROJECT=ddosd
ARCHITECTURE=bmv2

BUILD_DIR=build
LOG_DIR=logs
PCAP_DIR=pcaps
SOURCE_DIR=src
SCRIPT_DIR=scripts

P4C=/home/p4/p4sec/aclapolli-p4c/build/p4c
P4C_FLAGS:=-b $(ARCHITECTURE) -I$(SOURCE_DIR)

SOURCES:=$(wildcard $(SOURCE_DIR)/*.p4)

$(PROJECT): $(SOURCES)
	$(P4C) $(P4C_FLAGS) -o $(BUILD_DIR) $(SOURCE_DIR)/$(PROJECT).p4

run_plain:	$(PROJECT)
	./$(SCRIPT_DIR)/run_plain.sh

run_without_config:	$(PROJECT)
	./$(SCRIPT_DIR)/run_without_config.sh

run_mininet: $(PROJECT)
	./$(SCRIPT_DIR)/run_mininet.sh

clean:
	rm -rf $(BUILD_DIR) $(LOG_DIR) $(PCAP_DIR)

INTERFACE_PAIRS=8

veth_setup:	
	./$(SCRIPT_DIR)/run_veth.sh setup $(INTERFACE_PAIRS)

veth_delete:
	./$(SCRIPT_DIR)/run_veth.sh delete $(INTERFACE_PAIRS)

sniff_start:
	./$(SCRIPT_DIR)/run_wireshark.sh start

sniff_stop:
	./$(SCRIPT_DIR)/run_wireshark.sh stop 


# Experiments X, Y, Z. 

# PACKET_LIMIT=131072
# PACKET_RATE=2048

# PCAP_FILE=/media/p4/ddos/datasets/sample/ddos5y0.pcap			
# PCAP_FILE=/media/p4/ddos/datasets/zed/zed20percent.pcap
# PCAP_FILE=/media/p4/ddos/datasets/zed/zed20percent-notraining.pcap

# Experiments P4DAMP. 

# E01
# PACKET_LIMIT=172032 	
# PACKET_RATE=3072 		
# PCAP_FILE=/media/p4/ddos/datasets/zed/zed20percent-fast.pcap 
# sudo tcpreplay --preload-pcap --quiet --limit=$(PACKET_LIMIT) --pps=$(PACKET_RATE) -i veth0 $(PCAP_FILE) 2>&1

# E02
# PACKET_LIMIT=565248 
# PACKET_RATE=3072 	 
# PCAP_FILE=/media/p4/ddos/datasets/zed/zed20percent-fast.pcap 
# sudo tcpreplay --preload-pcap --quiet --limit=$(PACKET_LIMIT) --pps=$(PACKET_RATE) -i veth0 $(PCAP_FILE) 2>&1

################################################################################
# New Environment! 

SS_PREFIX="/home/p4/p4sec/aclapolli-bmv2/targets/simple_switch"
SS_CLI=$(SS_PREFIX)/simple_switch_CLI
TCPREPLAY=sudo tcpreplay --preload-pcap --quiet

PACKET_LIMIT=565248
PACKET_RATE=3072
PCAP_FILE=/media/p4/p4damp/datasets/zed/zed20percent-fast.pcap

exp_zed_10:
	$(SS_CLI) < /media/p4/ddosd-p4/scripts/p4d_ddos20/control_rules_base.txt
	$(SS_CLI) < /media/p4/ddosd-p4/scripts/p4d_ddos20/control_rules_zed.txt
	echo "register_write mitigation_t 0 10" | $(SS_CLI) 
	./$(SCRIPT_DIR)/run_capture_to_files.sh start
	$(TCPREPLAY) --limit=$(PACKET_LIMIT) --pps=$(PACKET_RATE) -i veth0 $(PCAP_FILE) 2>&1
	./$(SCRIPT_DIR)/run_capture_to_files.sh stop

# For the next experiment: 
# PCAP_FILE=/media/p4/p4damp/datasets/ddos20/ddos20.pcap
