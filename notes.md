Notes:
	The producer, data store(s), outbox, publisher, and message broker belong to bounded context "A".
	The subscriber, inbox, and consumer belong to bounded context "B"

TODO:
	Compare resiliency vs high availability
	Lookup how the AF change feed trigger scales
		The CosmosDB container will have some number of leases available. Each function can own one or more leases but a lease can only be owned by a single function instance. The number of leases is based on the number of partition key ranges (PKRs). PKRs are equivalent to physical partitions so in practice you can have at most one function instance per physical partition.
			This shouldn't be a problem as long as the processing at the function is kept optimized enough that the function can keep up with the input into the database. It's ok if the function lags behind a little. The definition of a "little" will depend on the use case.



Bounded context
Functional architecture - Technology agnostic 

Target audience for this article... at scale

Message broker is a buffer. It's not a database and it's not a cache.

Consider including a functional architecture.
Consider including a large graphic that includes:
Functional architecture
Event storming
Sequence diagram
Domain diagram

Add a note that the reader may already be familiar with the terms consumer/subscriber. Perhaps admit that my opinions are opinionated.

Replace the word adapter with service, ref clean architecture or whatever architecture style that comes from.

In this article we are going to dig into some of the aspects behind loosely coupled pub-sub messaging architectures. We'll quickly introduce a prototypical business case and the abstract event-driven architecture to support it. I will then do my best to convince you why loose coupling is important. Finally we'll take a look at what a loosely coupled cloud-native pub-sub architecture may look like on Azure ... try saying that five times fast.

No claims of resiliency and high availability
		That will be a different article discussing how to implement multi-region active-active pub-sub.

List paradigms, patterns, and practices being referenced in the article.
    Pub-sub - provide link
    Event Storming - provide link
    Event Driven Architecture
    DDD - Rethink this because I may not actually be using DDD in this article.
    Inbox/outbox - provide link
Tell the reader they are expected to be familiar with all of them.

Introduce the business case
    
    User sends CreateOrder command
    OrderService produces OrderCreated Event
    BillingService consumes OrderCreated
    BillingService produces OrderPaid
    ... end of event storming session ...

Convert the event storming session to a sequence diagram

    Client App > Order Service
    Order Service > Event Store (outbox)
    Event Store (outbox) > Publisher
    Publisher > Message Bus
    Message Bus > Subscriber
    Subscriber > Inbox
    Inbox > Billing Service