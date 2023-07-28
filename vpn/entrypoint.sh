#!/bin/sh

verify_required_parameter_is_set() {
  NAME=$1
  VALUE=$2
  if [ -z "${VALUE}" ]; then
    printf "\e[31m%s is not set\n\e[0m" "${NAME}"
    exit 1
  fi
  printf "\e[32m%s:\e[0m %s \n" "${NAME}" "${VALUE}"
}

# Test for presence of required vars
verify_required_parameter_is_set VPN_PROTOCOL "${VPN_PROTOCOL}"
OPENCONNECT_ARGS="--protocol ${VPN_PROTOCOL}"

verify_required_parameter_is_set VPN_SERVER "${VPN_SERVER}"
OPENCONNECT_ARGS="${OPENCONNECT_ARGS} --server ${VPN_SERVER}"

verify_required_parameter_is_set VPN_SERVER_CA_FILE "${VPN_SERVER_CA_FILE}"
OPENCONNECT_ARGS="${OPENCONNECT_ARGS} --cafile ${VPN_SERVER_CA_FILE}"

verify_required_parameter_is_set VPN_USER "${VPN_USER}"
OPENCONNECT_ARGS="${OPENCONNECT_ARGS} --user ${VPN_USER}"

verify_required_parameter_is_set VPN_USER_CERT "${VPN_USER_CERT}"
OPENCONNECT_ARGS="${OPENCONNECT_ARGS} --certificate ${VPN_USER_CERT}"

verify_required_parameter_is_set VPN_USER_KEY "${VPN_USER_KEY}"
OPENCONNECT_ARGS="${OPENCONNECT_ARGS} --sslkey ${VPN_USER_KEY}"

if [ -z "${VPN_PASS}" ]; then
  printf "\e[31m\$VPN_PASS is not set\e[0m\n"
  exit 1
fi
printf "\e[32mPassword:\e[0m [REDACTED]\n\n"

# Set command
OPENCONNECT_CMD="openconnect --background ${OPENCONNECT_ARGS} --passwd-on-stdin --non-inter"

printf "\e[32mStarting OpenConnect VPN...\e[0m\n"
printf "\e[33mArguments:\e[0m %s\n\n" "${OPENCONNECT_ARGS}"

# run open connect
(echo "${VPN_PASS}") | (eval "${OPENCONNECT_CMD}")

# run squid
sleep 4
echo "Loading Squid configuration..."
squid -f /vpn/squid.conf -z
sleep 2
echo "Starting Squid..."
squid -f /vpn/squid.conf -NYCd 1

