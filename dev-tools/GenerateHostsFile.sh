#!/usr/bin/env bash
# https://www.mypdns.org/
# Copyright: Content: https://gitlab.com/spirillen
# Source:Content:
#
# You are free to copy and distribute this file for non-commercial uses,
# as long the original URL and attribution is included.
#
# Please forward any additions, corrections or comments by logging an 
# issue at https://gitlab.com/my-privacy-dns/support/issues


# ******************
# Set Some Variables
# ******************

now=$(date '+%F %T %z (%Z)')
my_git_tag=V.${TRAVIS_BUILD_NUMBER}
activelist="${TRAVIS_BUILD_DIR}/dev-tools/output/domains/ACTIVE/list"
rawlist=${outdir}/raw.txt
bad_referrers=$(wc -l < ${rawlist})

# ********************
# Set the output files
# ********************

outdir="${TRAVIS_BUILD_DIR}/download_here" # no trailing / as it would make a double //

# ordinary without safe search records
hosts="${outdir}/0.0.0.0/hosts"
hosts127="${outdir}/127.0.0.1/hosts"
mobile="${outdir}/mobile/hosts"
dnsmasq="${outdir}/dnsmasq/pornhosts.conf"
rpz="${outdir}/rpz/pornhosts.rpz"
unbound="${outdir}/unbound/pornhosts.con"

# Safe Search enabled output
ssoutdir="${outdir}/safesearch" # no trailing / as it would make a double //

sshosts="${ssoutdir}/0.0.0.0/hosts"
sshosts127="${ssoutdir}/127.0.0.1/hosts"
ssmobile="${ssoutdir}/mobile/hosts"
ssdnsmasq="${ssoutdir}/dnsmasq/dnsmasq.conf"
ssrpz="${ssoutdir}/rpz/pornhosts.rpz"
ssunbound="${ssoutdir}/unbound/pornhosts.conf"

# ******************
# Set templates path
# ******************
templpath="${TRAVIS_BUILD_DIR}/dev-tools/templates"

hostsTempl=${templpath}/hosts.template
mobileTempl=${templpath}/dev-tools/mobile.template
dnsmasqTempl=${templpath}/ddwrt-dnsmasq.template
#unboundTempl # None as we print the header directly

# Safe Search is in subpath

# TODO Get templates from the master source at 
# https://gitlab.com/my-privacy-dns/matrix/matrix/tree/master/safesearch
# Template file for 0.0.0.0 and 127.0.0.1 are the same

sstemplpath="${templpath}/safesearch"

sshostsTempl="${sstemplpath}/hosts.template" # same for mobile
ssdnsmasqTempl="${sstemplpath}/ddwrt-dnsmasq.template"
ssrpzTempl="${sstemplpath}/safesearch.rpz"
ssunboundTempl="${sstemplpath}/"

# ***********************************************************
echo Update our safe search templates
# ***********************************************************

wget -qO sshosts 'https://gitlab.com/my-privacy-dns/rpz-dns-firewall-tools/hosts/raw/master/matrix/safesearch.hosts'
wget -qO ssdnsmasq 'https://gitlab.com/my-privacy-dns/rpz-dns-firewall-tools/dnsmasq/raw/master/safesearch.dnsmasq.conf'
wget -qO ssrpz 'https://gitlab.com/my-privacy-dns/rpz-dns-firewall-tools/bind-9/raw/master/safesearch.mypdns.cloud.rpz'
wget -qO ssunbound 'https://gitlab.com/my-privacy-dns/rpz-dns-firewall-tools/unbound/raw/master/safesearch.conf'

# First let us clean out old data in output folders

find "${outdir}" -type f -delete

# Next ensure all output folders is there

bash "${TRAVIS_BUILD_DIR}/dev-tools/make_output_dirs.sh (`grep -vE '^$' ${TRAVIS_BUILD_DIR}/dev-tools/output_dirs.txt`)"

# Generate the rawlist, as we need it for the rest of our work

grep -vE "^(#|$)" ${activelist} > ${rawlist}

# Strip out Whitelisted Domains and False Positives

uhb_whitelist -wc -m -p 4 -w "${TRAVIS_BUILD_DIR}/submit_here/whitelist.txt" -f ${rawlist} -o ${rawlist}

# *******************************
echo "Generate hosts 0.0.0.0"
# *******************************

printf "### Updated: ${now} Build: ${my_git_tag}\n### Porn Hosts Count: ${bad_referrers}\n" > ${hosts}
cat ${hostsTempl} >> ${hosts}
awk '{ printf("0.0.0.0\t%s\n",tolower($1)) }' "${activelist}" >> ${hosts}

# *******************************
echo "Generate safe hosts 0.0.0.0"
# *******************************

printf "### Updated: ${now} Build: ${my_git_tag}\n### Porn Hosts Count: ${bad_referrers}\n" > ${sshosts}
cat ${hostsTempl} >> ${sshosts}
cat ${sshostsTempl} >> ${sshosts}
awk '{ printf("0.0.0.0\t%s\n",tolower($1)) }' "${activelist}" >> ${sshosts}

# *******************************
echo "Generate hosts 127.0.0.1"
# *******************************

printf "### Updated: ${now} Build: ${my_git_tag}\n### Porn Hosts Count: ${bad_referrers}\n" > ${hosts127}
cat ${hostsTempl} >> ${hosts127}
awk '{ printf("127.0.0.1\t%s\n",tolower($1)) }' "${activelist}" >> ${hosts127}

# **********************************
echo "Generate safe hosts 127.0.0.1"
# **********************************

printf "### Updated: ${now} Build: ${my_git_tag}\n### Porn Hosts Count: ${bad_referrers}\n" > ${sshosts127}
cat ${hostsTempl} >> ${sshosts127}
cat ${sshostsTempl} >> ${sshosts127}
awk '{ printf("127.0.0.1\t%s\n",tolower($1)) }' "${activelist}" >> ${sshosts127}

# *******************************
echo "Generate Mobile hosts"
# *******************************

printf "### Updated: ${now} Build: ${my_git_tag}\n### Porn Hosts Count: ${bad_referrers}\n" > ${mobile}
cat ${mobileTempl} >> ${mobile}
awk '{ printf("0.0.0.0\t%s\n",tolower($1)) }' "${activelist}" >> ${mobile}

# *******************************
echo "Generate safe Mobile hosts"
# *******************************

printf "### Updated: ${now} Build: ${my_git_tag}\n### Porn Hosts Count: ${bad_referrers}\n" > ${ssmobile}
cat ${mobileTempl} >> ${ssmobile}
cat ${ssmobileTempl} >> ${ssmobile}
awk '{ printf("0.0.0.0\t%s\n",tolower($1)) }' "${activelist}" >> ${ssmobile}



# *********************************************************************************
# DNSMASQ https://gitlab.com/my-privacy-dns/rpz-dns-firewall-tools/dnsmasq/issues/1
# *********************************************************************************

printf "### Updated: ${now} Build: ${my_git_tag}\n### Porn Hosts Count: ${bad_referrers}\n" > ${dnsmasq}
cat ${dnsmasqTempl} >> ${dnsmasq}
awk '{ printf("server=/%s/\n",tolower($1)) }' "${activelist}" >> ${dnsmasq}

# **********************************
echo "build Safe search for dnsmasq"
# **********************************

printf "### Updated: ${now} Build: ${my_git_tag}\n### Porn Hosts Count: ${bad_referrers}\n" > ${ssdnsmasq}
cat ${ssdnsmasqTempl} >> ${ssdnsmasq}
awk '{ printf("server=/%s/\n",tolower($1)) }' "${activelist}" >> ${ssdnsmasq}



# ********************************************************
# UNBOUND
# ********************************************************

# **************************************
echo "Unbound zone file always_nxdomain"
# **************************************

printf '{server:\n}' > "${unbound}"
awk '{ printf("local-zone: \"%s\" always_nxdomain\n",tolower($1)) }' "${activelist}" >> "${unbound}"

# **************************************************
echo "Unbound safe search zone file always_nxdomain"
# **************************************************

cat ${ssunboundTempl} > ${unbound}
awk '{ printf("local-zone: \"%s\" always_nxdomain\n",tolower($1)) }' "${activelist}" >> "${unbound}"



# ********************************************************
# RPZ formatted
# ********************************************************

# ************************************
echo "Make Bind format RPZ"
# ************************************

cat ${rpzTempl} > ${rpz}
printf "\$TTL 1w;
\$ORIGIN\tlocalhost.
\tSOA\tneed.to.know.only. hostmaster.mypdns.org. `date +%s` 3600 60 604800 60;
\tNS\tlocalhost\n" > "${rpz}"

awk '{ printf("%s\tCNAME\t.\n*.%s\tCNAME\t.\n",tolower($1),tolower($1)) }' "${activelist}" >> "${rpz}"

exit ${?}
