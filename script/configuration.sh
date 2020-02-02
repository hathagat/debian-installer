#!/bin/bash

list_infos() {
  trap error_exit ERR

  echo "Please save the shown credentials:"
  echo
  echo "-----BEGIN CREDENTIALS-----"
  cat ${SCRIPT_PATH}/login_information.txt
  echo "-----END CREDENTIALS-----"
  echo
  echo "Please save the shown SSH privatekey:"
  echo
  cat ${SCRIPT_PATH}/ssh_privatekey.txt

  cat<<EOF

If you want to connect to this server with Putty or the like, you need to generate an appropriate key:

- Download the latest PuTTYgen at https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
- Start the tool and click on "Conversions" - "Import key"
- Save your SSH privatekey in a text file and select it here
- After entering your SSH password switch the paramter from RSA to ED25519
- Click on "Save private key"

Don't forget to change your SSH Port when you try to connect to this server. ;-)

EOF
}
