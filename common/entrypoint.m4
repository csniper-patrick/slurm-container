#!/bin/bash

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.10.0
# ARG_OPTIONAL_SINGLE([clustername], , [name of the cluster, required for init], [slurm])
# ARG_OPTIONAL_SINGLE([role], , [slurmctld(default)|slurmdbd|slurmd|slurmrestd], [slurmctld])
# ARG_OPTIONAL_SINGLE([slurmdbd-hosts])
# ARG_OPTIONAL_SINGLE([slurmctld-hosts])
# ARG_OPTIONAL_SINGLE([db])
# ARG_OPTIONAL_SINGLE([dbhost])
# ARG_OPTIONAL_SINGLE([dbuser])
# ARG_OPTIONAL_SINGLE([dbpass])
# ARG_OPTIONAL_BOOLEAN([init])
# ARG_OPTIONAL_BOOLEAN([keygen])
# ARG_OPTIONAL_BOOLEAN([configless])
# ARGBASH_SET_DELIM([ =])
# ARG_OPTION_STACKING([getopt])
# ARG_RESTRICT_VALUES([no-local-options])
# ARG_HELP([<The general help message of my script>])
# ARGBASH_GO

# [ <-- needed because of Argbash

# vvv  PLACE YOUR CODE HERE  vvv
# For example:
printf 'Value of --%s: %s\n' 'clustername' "$_arg_clustername"
printf 'Value of --%s: %s\n' 'role' "$_arg_role"
printf 'Value of --%s: %s\n' 'slurmdbd-hosts' "$_arg_slurmdbd_hosts"
printf 'Value of --%s: %s\n' 'slurmctld-hosts' "$_arg_slurmctld_hosts"
printf 'Value of --%s: %s\n' 'db' "$_arg_db"
printf 'Value of --%s: %s\n' 'dbhost' "$_arg_dbhost"
printf 'Value of --%s: %s\n' 'dbuser' "$_arg_dbuser"
printf 'Value of --%s: %s\n' 'dbpass' "$_arg_dbpass"
printf "'%s' is %s\\n" 'init' "$_arg_init"
printf "'%s' is %s\\n" 'keygen' "$_arg_keygen"
printf "'%s' is %s\\n" 'configless' "$_arg_configless"

# input validation

# SLURM_ROLE
SLURM_ROLE=${SLURM_ROLE:=$_arg_role}
[[ ${SLURM_ROLE} == slurmctld ]] || [[ ${SLURM_ROLE} == slurmdbd ]] || [[ ${SLURM_ROLE} == slurmd ]] || [[ ${SLURM_ROLE} == slurmrestd ]] || ( echo Invalid role "${SLURM_ROLE}" && exit 128 )

# SLURMCTLD_HOSTS List
SLURMCTLD_HOSTS=${SLURMCTLD_HOSTS:=$_arg_slurmctld_hosts}

# SLURMDBD_HOSTS List
SLURMDBD_HOSTS=${SLURMDBD_HOSTS:=$_arg_slurmdbd_hosts}

# CLUSTERNAME
CLUSTERNAME=${CLUSTERNAME:=$_arg_clustername}

# MySQL/MariaDB config
MYSQL_DATABASE=${MYSQL_DATABASE:=$_arg_db}
MYSQL_USER=${MYSQL_USER:=$_arg_dbuser}
MYSQL_PASSWORD=${MYSQL_PASSWORD:=$_arg_dbpass}
MYSQL_HOST=${MYSQL_HOST:=$_arg_dbhost}

# on/off configs
CONF_INIT=${CONF_INIT:=$_arg_init}
[[ ${CONF_INIT} == on ]] || [[ ${CONF_INIT} == off ]] || ( echo CONF_INIT must be on/off && exit 128 )

KEYGEN=${KEYGEN:=$_arg_keygen}
[[ ${KEYGEN} == on ]] || [[ ${KEYGEN} == off ]] || ( echo KEYGEN must be on/off && exit 128 )

CONFIGLESS=${CONFIGLESS:=$_arg_configless}
[[ ${CONFIGLESS} == on ]] || [[ ${CONFIGLESS} == off ]] || ( echo CONFIGLESS must be on/off && exit 128 )

check_config_file () {
	# generate slurmdbd.conf if necessary
	( [[ -f /etc/slurm/slurmdbd.conf ]] && [[ ${CONF_INIT} == off ]] ) || [[ ! ${SLURM_ROLE} == slurmdbd ]] \
	|| /opt/entrypoint/bin/jinja2 \
		-D MYSQL_HOST=${MYSQL_HOST:?MYSQL_HOST is unset or null} \
		-D MYSQL_USER=${MYSQL_USER:?MYSQL_USER is unset or null} \
		-D MYSQL_PASSWORD=${MYSQL_PASSWORD:?MYSQL_PASSWORD is unset or null} \
		-D MYSQL_DATABASE=${MYSQL_DATABASE:?MYSQL_DATABASE is unset or null} \
		-D SLURMDBD_HOSTS=${SLURMDBD_HOSTS:?SLURMDBD_HOSTS is unset or null} \
		/opt/entrypoint/slurmdbd.conf.j2 > /etc/slurm/slurmdbd.conf
	
	# generate slurm.conf if necessary
	( [[ -f /etc/slurm/slurm.conf ]] && [[ ${CONF_INIT} == off ]] ) || [[ ! ${SLURM_ROLE} == slurmctld ]] \
	|| /opt/entrypoint/bin/jinja2 \
		-D SLURMCTLD_HOSTS=${SLURMCTLD_HOSTS:?SLURMCTLD_HOSTS is unset or null} \
		-D CLUSTERNAME=${CLUSTERNAME:?CLUSTERNAME is unset or null} \
		-D SLURMDBD_HOSTS=${SLURMDBD_HOSTS} \
		-D CONFIGLESS=${CONFIGLESS} \
		/opt/entrypoint/slurm.conf.j2 > /etc/slurm/slurm.conf
	
	# generate cgroup.conf if necessary
	( [[ -f /etc/slurm/cgroup.conf ]] && [[ ${CONF_INIT} == off ]] ) || ! grep -q -E "^ProctrackType=proctrack/cgroup$" /etc/slurm/slurm.conf || /opt/entrypoint/bin/jinja2 /opt/entrypoint/cgroup.conf.j2 > /etc/slurm/cgroup.conf

	# generate jwks if necessary

	# generate /etc/slurm/slurm.key if necessary

	# ensure correct file permission and ownership

}

set -x

if [[ ${SLURM_ROLE} == slurmctld ]] ; then
	# Role slurmctld
	check_config_file
	echo mode ${SLURM_ROLE}
elif [[ ${SLURM_ROLE} == slurmdbd ]] ; then
	# Role slurmdbd
	check_config_file
	echo mode ${SLURM_ROLE}
elif [[ ${SLURM_ROLE} == slurmd ]] ; then
	# Role slurmd
	echo mode ${SLURM_ROLE}
elif [[ ${SLURM_ROLE} == slurmrestd ]] ; then
	# Role slurmrestd
	echo mode ${SLURM_ROLE}

fi

# ^^^  TERMINATE YOUR CODE BEFORE THE BOTTOM ARGBASH MARKER  ^^^

# ] <-- needed because of Argbash
