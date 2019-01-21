#!/bin/bash

set -eu

cassandra-stress write \
	cl=QUORUM n=${count} \
	-mode native cql3 user="${username}" password="${password}" \
	-rate threads=350 limit='${limit}/s' \
	-node "${seeds}" \
	-pop seq=${range_from}..${range_to}
