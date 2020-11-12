#!/bin/bash
#
# This script creates a new user on the local system
# you must supply a username as an argument to the script
# optionally you can also provide a comment for the account as an argument
# a password will be automatically generated for the account
# the username, password, and host for the account will be displayed

# make sure the script is being executed with superuser privileges
if [[ "${UID}" -ne 0 ]]
then
	echo "Please run with sudo or as root."
	exit 1
fi

# if they don't supply at least onw argument then give them help
if [[ "${#}" -lt 1 ]]
then
	echo "Usage: ${0} USER_NAME [COMMENT]..."
	echo "Create an account on the local system with the name of USER_NAME and comments field of COMMENT."
	exit 1
fi

# the first parameter is the user name
USER_NAME="${1}"

# The rest of the parameters are for the account comments.
shift
COMMENT="${@}"

# Generate a password
PASSWORD=$(date +%s%N | sha256sum | head -c48)

# Create the user with the password.
useradd -c "${COMMENT}" -m ${USER_NAME}

# check to see if the useradd command succeeed
# we don't wanna tell the user than an account was created when it hasn't been
if [[ "${?}" -ne 0]]
then
	echo "The account could not be created."
	exit 1
fi

# set the password.
echo ${PASSWORD} | passwd --stdin ${USER_NAME}

# check to see if the passwd command succeeded.

if [[ "${?}" -ne 0]]
then
	echo "The password for the account could not be set"
	exit 1
fi

# Force password change on first login
passwd -e ${USER_NAME}

# Disply he username, password, and the host where the user was created
echo
echo Username:
echo "${USER_NAME}"
echo
echo Password:
echo "${PASSWORD}"
echo
echo Host:
echo "${HOSTNAME}"
exit 0
