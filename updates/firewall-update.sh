#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

update_firewall() {

	trap error_exit ERR

	apt-get update
}
