# terraform-aws-scylla-bench

Terraform module for load testing a Scylla cluster with scylla-bench.

## Why

Profiling Scylla cluster is often limited by network throughput of a host running `scylla-bench` utility (or `cassandra-stress` one). Also to minimalize network latency effect it is best to colocate `scylla-bench` nodes near datacenters the cluster is running in. To perform an efficient load the following factors need to be considered:

- run `scylla-bench` from host being as close to the cluster as possible
- ensure the host is capable of withstanding sufficient bandwidth
- speed up by sharding the load among a number of concurrent `scylla-bench` hosts

In addition the procedure usually involves a number of simple steps, which this Terraform module helps to automate:

- concurrently spawns a number of EC2 instances
  - amount of the instances is configured by `instances` variable (`4` being a default)
  - size of a single instance is controlled by `aws_instance_type` variable (`c4.large` being a default)
- provisions the instances to prepare for the load
- loads the schema from a single instance and waits until it's propagated
  - schema can be configured by `schema` variable (`replication(factor=3)` being a default)
  - for more complex usecases schema script can also be configured with `create_schema_script` variable (`scripts/create-schema.sh` being a default)
- once the environment is ready, the load begins:
  - there are a number of variables, that can alter the default behaviour: consult [Variables section](./Variables) for more information
  - the load script itself can also be overwritten with `write_script` variables (`scripts/write.sh` being a default)
 
Once the load if finished (the fact needs to be observed externally, e.g. using (Scylla Monitoring)(https://github.com/scylladb/scylla-grafana-monitoring/) stack), the infrastracture created by this module can be safely teared down.

## Example

```
$ cat main.tf 
```
```hcl
module "scylla-bench" {
	source  = "github.com/rjeczalik/terraform-aws-scylla-bench"
	username = "scylla_admin"
	password = "qwerty123"
	seeds = ["66.249.65.11", "66.249.66.11", "66.249.67.11"]
	instances = 4
	keys = 1000000000
	limit = 10000
}
```

## Usage

Once you configure the module, start the profiling with:

```
$ terraform apply
```

When it finishes, tear it down with:

```
$ terraform destroy
```

## Variables



## TODO

- add support for profile-driven loads (uploading profile file)
- add support for spot instances
- add support for external VPC (private cluster + vpc peering)
