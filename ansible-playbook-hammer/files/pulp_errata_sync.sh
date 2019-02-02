#!/bin/bash -ex

cd /opt/pulp_centos_errata_import/

wget -N http://cefs.steve-meier.de/errata.latest.xml
wget -N https://www.redhat.com/security/data/oval/com.redhat.rhsa-all.xml

/bin/date +%Y%m%d_%H%M > ./START_PULP_SYNC

# pulp-admin repo list --fields display_name | grep -B1 -E "(base|extras|updates)" | awk '/Id/ { print $NF }'

ARRAY=(`pulp-admin repo list --fields display_name | grep -B1 -E "(base|extras|updates)" | awk '/Id/ { printf(" \""); printf($2); printf("\"") }'`)

base=$(echo "${ARRAY[0]}" | tr -d "\"")
extras=$(echo "${ARRAY[1]}" | tr -d "\"")
updates=$(echo "${ARRAY[2]}" | tr -d "\"")

perl ./errata_import.pl \
  --errata=errata.latest.xml \
  --rhsa-oval=com.redhat.rhsa-all.xml \
  --include-repo=${base} \
  --include-repo=${extras} \
  --include-repo=${updates} \
  --asdf

/bin/date +%Y%m%d_%H%M > ./STOP_PULP_SYNC

declare -a arr=("base_x86_64" "extras_x86_64" "updates_x86_64")

/bin/date +%Y%m%d_%H%M > ./START_REPO_SYNC

for i in "${arr[@]}"; do
  hammer repository synchronize \
    --organization lxd \
    --skip-metadata-check true \
    --product custom \
    --name $i;
done

/bin/date +%Y%m%d_%H%M > ./STOP_REPO_SYNC
