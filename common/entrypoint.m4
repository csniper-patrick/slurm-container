#!/bin/bash

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.10.0
# ARG_OPTIONAL_SINGLE([clustername], , [name of the cluster, required for init.\nenv var: CLUSTERNAME], )
# ARG_OPTIONAL_SINGLE([role], , [slurmctld(default)|slurmdbd|slurmd|slurmrestd|sackd.\nenv var: SLURM_ROLE], [slurmctld])
# ARG_OPTIONAL_SINGLE([slurmdbd-hosts], , [comma separated list of slurmdbd hosts.\nenv var: SLURMDBD_HOSTS], )
# ARG_OPTIONAL_SINGLE([slurmctld-hosts], , [comma seperated list of slurmctld hosts.\nenv var: SLURMCTLD_HOSTS], )
# ARG_OPTIONAL_SINGLE([db], , [database name.\nenv var: MYSQL_DATABASE], )
# ARG_OPTIONAL_SINGLE([dbhost], , [mariadb database hostname.\nenv var: SLURMDBD_STORAGEHOST], )
# ARG_OPTIONAL_SINGLE([dbuser], , [database user.\nenv var: MYSQL_USER], )
# ARG_OPTIONAL_SINGLE([dbpass], , [database password.\nenv var: MYSQL_PASSWORD], )
# ARG_OPTIONAL_BOOLEAN([init], , [regenerate configuration.\nenv var: CONF_INIT], )
# ARG_OPTIONAL_BOOLEAN([keygen], , [regenerate jwks.json and slurm.key.\nenv var: KEYGEN], )
# ARG_OPTIONAL_BOOLEAN([configless], , [use configless mode. When enabled only slurm.key need to distributed to compute and client nodes.\nenv var: CONFIGLESS], )
# ARGBASH_SET_DELIM([ =])
# ARG_OPTION_STACKING([getopt])
# ARG_RESTRICT_VALUES([no-local-options])
# ARG_HELP([Containerized Slurm control plane])
# ARGBASH_GO

# [ <-- needed because of Argbash

# vvv  PLACE YOUR CODE HERE  vvv
# input validation

# SLURM_ROLE
SLURM_ROLE=${SLURM_ROLE:=$_arg_role}
[[ ${SLURM_ROLE} == slurmctld ]] || [[ ${SLURM_ROLE} == slurmdbd ]] || [[ ${SLURM_ROLE} == slurmd ]] || [[ ${SLURM_ROLE} == slurmrestd ]] || [[ ${SLURM_ROLE} == sackd ]] || ( echo Invalid role "${SLURM_ROLE}" && exit 128 )

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
SLURMDBD_STORAGEHOST=${SLURMDBD_STORAGEHOST:=$_arg_dbhost}

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
	|| ( /opt/local/bin/jinja2 \
		-D SLURMDBD_STORAGEHOST=${SLURMDBD_STORAGEHOST:?SLURMDBD_STORAGEHOST is unset or null} \
		-D MYSQL_USER=${MYSQL_USER:?MYSQL_USER is unset or null} \
		-D MYSQL_PASSWORD=${MYSQL_PASSWORD:?MYSQL_PASSWORD is unset or null} \
		-D MYSQL_DATABASE=${MYSQL_DATABASE:?MYSQL_DATABASE is unset or null} \
		-D SLURMDBD_HOSTS=${SLURMDBD_HOSTS:?SLURMDBD_HOSTS is unset or null} \
		/opt/local/slurmdbd.conf.j2 > /etc/slurm/slurmdbd.conf && chmod 0600 /etc/slurm/slurmdbd.conf )
	
	# generate slurm.conf if necessary
	SLURMCTLD_PARAMETERS=""
	[[ ${CONFIGLESS} == on ]] && SLURMCTLD_PARAMETERS+="enable_configless"
	( [[ -f /etc/slurm/slurm.conf ]] && [[ ${CONF_INIT} == off ]] ) || [[ ! ${SLURM_ROLE} == slurmctld ]] \
	|| /opt/local/bin/jinja2 \
		-D SLURMCTLD_HOSTS=${SLURMCTLD_HOSTS:?SLURMCTLD_HOSTS is unset or null} \
		-D CLUSTERNAME=${CLUSTERNAME:?CLUSTERNAME is unset or null} \
		${SLURMCTLD_PARAMETERS:+-D SLURMCTLD_PARAMETERS=${SLURMCTLD_PARAMETERS}} \
		${SLURMDBD_HOSTS:+-D SLURMDBD_HOSTS=${SLURMDBD_HOSTS}} \
		${CONFIGLESS:+-D CONFIGLESS=${CONFIGLESS}} \
		/opt/local/slurm.conf.j2 > /etc/slurm/slurm.conf
	
	# generate cgroup.conf if necessary
	( [[ -f /etc/slurm/cgroup.conf ]] && [[ ${CONF_INIT} == off ]] ) || ! grep -q -E "^ProctrackType=proctrack/cgroup$" /etc/slurm/slurm.conf || /opt/local/bin/jinja2 /opt/local/cgroup.conf.j2 > /etc/slurm/cgroup.conf

	# generate jwks if necessary

	for public_key in $( grep -h -E "^AuthAltParameters=" /etc/slurm/slurm*.conf | cut -c19- | tr ',' '\n' | grep -h -E "^jwks=" | cut -c6- ) ; do
		private_key=${public_key}.priv
		( [[ -f ${public_key} ]] && [[ ${KEYGEN} == off ]] ) || ( java -jar /opt/local/lib/json-web-key-generator.jar --type RSA --size 2048 --algorithm RS256 --idGenerator sha1 --keySet --output ${private_key} --pubKeyOutput ${public_key} && chmod 0644 ${public_key} && chmod 0600 ${private_key} )
	done

	# generate /etc/slurm/slurm.jwks if necessary
	( ( [[ -f /etc/slurm/slurm.jwks ]] || [[ -f /etc/slurm/slurm.key ]] ) && [[ ${KEYGEN} == off ]] ) \
	|| ( java -jar /opt/local/lib/json-web-key-generator.jar --type oct --size 2048 --algorithm HS256 --idGenerator sha1 --keySet --output /etc/slurm/slurm.jwks && chmod 0600 /etc/slurm/slurm.jwks )

	# generate /etc/slurm/slurm.key if necessary
	( [[ -f /etc/slurm/slurm.key ]] && [[ ${KEYGEN} == off ]] ) \
	|| ( dd if=/dev/random of=/etc/slurm/slurm.key bs=1024 count=1 && chmod 0600 /etc/slurm/slurm.key )

	# ensure correct directory ownership
	slurm_user=$(grep -h -E "^SlurmUser=" /etc/slurm/slurm*.conf | cut -c11- | head -n1)
	slurm_group=$(id -gn ${slurm_user})

	for slurm_dir in $(grep -h -E "^(StateSaveLocation)=" /etc/slurm/slurm*.conf | cut -d= -f2-) /run/slurmdbd /run/slurmctld /var/log/slurm ; do
		mkdir -pv ${slurm_dir} && chown ${slurm_user}:${slurm_group} ${slurm_dir}
	done

	for slurm_file in $(grep -h -E "^(SlurmctldLogFile|SlurmctldPidFile|SlurmctldLogFile|LogFile|PidFile)=" /etc/slurm/slurm*.conf | cut -d= -f2-) ; do
		touch ${slurm_file} && chown ${slurm_user}:${slurm_group} ${slurm_file}
	done

	chown -R ${slurm_user}:${slurm_group} /etc/slurm /var/spool/slurmctld 
}

set -x

case "${SLURM_ROLE}" in
    slurmctld)        
		# Role slurmctld
		check_config_file
		run_user=$(grep -h -E "^SlurmUser=" /etc/slurm/slurm.conf | cut -c11- | head -n1)
		sudo -u ${run_user} slurmctld -D -v $SLURMCTLD_OPTIONS
        ;;
    slurmdbd)
		# Role slurmdbd
		check_config_file
		run_user=$(grep -h -E "^SlurmUser=" /etc/slurm/slurmdbd.conf | cut -c11- | head -n1)
		sudo -u ${run_user} slurmdbd -D -s -v ${SLURMDBD_OPTIONS}
        ;;
    slurmd)
		# Role slurmd
		# setting environment
		SLURMD_OPTIONS="-Z "
		[[ ${CONFIGLESS} == on ]] && SLURMD_OPTIONS+="${SLURMCTLD_HOSTS:+--conf-server ${SLURMCTLD_HOSTS}}"
		cat > /etc/sysconfig/slurmd <<-EOF
			SLURMD_OPTIONS="${SLURMD_OPTIONS}"
			EOF
		exec /sbin/init
        ;;
    slurmrestd)
		# Role slurmrestd
		export SLURMRESTD_SECURITY=DISABLE_USER_CHECK
		export SLURM_JWT=daemon
		slurmrestd -v $SLURMRESTD_OPTIONS 0.0.0.0:6820
        ;;
    sackd)
		# Role sackd
		[[ -d /run/slurm/conf ]] || mkdir -pv /run/slurm/conf
		SACKD_OPTIONS="-D -v "
		[[ ${CONFIGLESS} == on ]] && SACKD_OPTIONS+="${SLURMCTLD_HOSTS:+--conf-server ${SLURMCTLD_HOSTS}}"
		sackd ${SACKD_OPTIONS}
        ;;
esac

# ^^^  TERMINATE YOUR CODE BEFORE THE BOTTOM ARGBASH MARKER  ^^^

# ] <-- needed because of Argbash
