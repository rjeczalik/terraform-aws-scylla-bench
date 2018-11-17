#!/bin/bash

set -eu

cassandra-stress write \
	n=1 cl=ALL -schema "${schema}" \
	-mode native cql3 user="${username}" password="${password}" \
	-node "${first_seed}"
