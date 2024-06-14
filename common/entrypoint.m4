#!/bin/bash

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.10.0
# ARG_OPTIONAL_SINGLE([role])
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

# ^^^  TERMINATE YOUR CODE BEFORE THE BOTTOM ARGBASH MARKER  ^^^

# ] <-- needed because of Argbash
