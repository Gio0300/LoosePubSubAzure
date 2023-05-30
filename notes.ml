Notes:
	The producer, data store(s), outbox, publisher, and message broker belong to bounded context "A".
	The subscriber, inbox, and consumer belong to bounded context "B"

TODO:
	Compare resiliency vs high availability
	Lookup how the AF change feed trigger scales
		The CosmosDB container will have some number of leases available. Each function can own one or more leases but a lease can only be owned by a single function instance. The number of leases is based on the number of partition key ranges (PKRs). PKRs are equivalent to physical partitions so in practice you can have at most one function instance per physical partition.
			This shouldn't be a problem as long as the processing at the function is kept optimized enough that the function can keep up with the input into the database. It's ok if the function lags behind a little. The definition of a "little" will depend on the use case.
