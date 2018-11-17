#!/bin/bash

set -eu

cassandra-stress write \
	cl=QUORUM n=${count} \
	-mode native cql3 user="${username}" password="${password}" \
	-rate threads=350 limit='10000/s' \
	-node "${first_seed}" \
	-pop seq=${range_from}..${range_to}
