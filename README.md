# Loosely coupled pub-sub on Azure






Let's start with some definitions to make sure we have a shared understanding of the terms. In particular I am going to make a firm distinction between the terms producer and publisher as well as subscribers and consumers. These terms are often used interchangeably in high level system designs. But once we get into implementation details the distinction becomes necessary.



## Producers & Publishers
A producer is a business construct responsible for creating an event based on business rules. Producing events is strictly a business concern, the producer is divorced from any and all infrastructure related responsibility. Much like the business logic isn't responsible for data persistance which is typically delegated to a database. Producers are not responsible for publishing events. That responsibility is delegated to the publisher.

A publisher is component from the infrastructure layer responsible for marshaling events from the event store to the message bus. The Publisher sets the terms of the integration with subscribers. It owns the message bus and its operational policies. The publisher is a commodity, a technical detail, the publisher should not encompass any business knowledge. How it's implemented is dictated by the operating infrastructure.

### Reasons to separate producers and publishers
#### Separation of concern
Publishing events is a complex endeavour. Publishers must deal with the idiosyncrasies of the message bus solution, integration policies, geo-replication, availability, retries, replays, queue & log semantics, partitions, sessions, ordering, deduplication, tracing. Producers should not be burdened with such technical details.
#### Reduce distributed transactions
Separating the roles eliminates the need for a distributed transaction between the event store and the message bus. The producer, a component within the business layer, need only to emit the domain event, the application and infrastructure layers will marshal the event to the event store in a single transaction.

The publisher will eventually publish the event in a separate transaction. With this arrangement the producer is free to operate even when there is an outage on the publishing side.

#### Independent scaling
The scaling profile of the producer may be widely different than that of the publisher. Consider an application where the producer is a real-time service that accepts customer orders. The producer will need to be scaled in direct relation to customer demand, maybe this demand is seasonal, maybe it's unpredictable. Once an order is placed successfully the rest of the order processing workflow may run at a predictable rate. In this example the publisher may be scaled to provide a fixed throughput in order to provide load leveling for the rest of the system. Now consider a scenario were a large number of events need to be republished, perhaps for a new analytics workflow or to hydrate the message bus after recovering from a disaster. In such cases the publisher may be scaled out temporarily to provide increased throughput without affecting the producer.

#### Independent deployment
As the business evolves so must the producer. The producer will need to be update regularly, specially in the early days of development. On the other hand the publisher is a commodity. The publisher should be blissfully ignorant of business logic and thus should have very little reason to change. Separating the roles allows the producer to be maintained and deployed independently from the the publisher.

### High availability, business continuation, and disaster recovery
A loosely coupled pub-sub architecture does not inherently provide high availability, business continuation, and disaster recovery, at least not directly. What it does provide is the flexibility to introduce HA/BC/DR into any-and-all parts of the system as the business needs evolve. 

## Subscribers & Consumers
A subscriber is a component from the infrastructure layer responsible for marshaling events from the message bus to the consumer of the event. Its purpose is to abstract the messaging infrastructure from the consumer. You can think of the subscriber a mirrored counterpart of the publisher. Just like the publisher, the subscriber is a commodity, a technical detail and it also should not encompass any business logic. Its implementation is dictated by the infrastructure.

A consumer is a business construct responsible for reacting to a domain event. Consuming events is a business concern and so the behavior of the consumer is dictated by business rules. As the subscriber is the mirrored counterpart of the publisher so is the consumer the mirror counterpart of the producer.

### Reason to separate subscribers and consumers
In the interest of brevity I will summarize the reasons to separate subscribers and consumers as roughly the same reasons given above for the producers and publishers. There are some differences of course but the principals are the same.

## From abstract to concrete
Now it's time to move into an implementation plan. Because the subject of this article is loosely coupled pub-sub I will skim over the intricacies of event driven architecture and microservices to focus on pub-sub constructs. It goes without saying that the implementation plan I am proposing is simply one of many possible solutions. Your solution will likely vary.

### Client App
The client application is the first component in the functional sequence diagram but it's only present to illustrate the end-to-end flow. The client app is one of the components that we will largely ignore because its role is inconsequential to the pub-sub architecture.
### Order Service - <i><<Producer\>\></i>
The order service is the first actor in the pub-sub architecture, after all it's the producer of the order_created event. In terms of a loosely coupled pub-sub architecture hosted on Azure it can be implemented using any of the [compute solutions on offer](https://learn.microsoft.com/en-us/azure/architecture/guide/technology-choices/compute-decision-tree).

TODO: left off here.


## Principals of loosely coupled pub-sub architectures
If you take away anything from this article let it be these principals.
* Producers and consumers are business concerns.
* Publishers and subscribers are infrastructure component. They are a technical detail.
* Producers must not be aware of consumers.
* Producers must not be aware of their supporting publisher. Consumers must not be aware of their supporting subscriber.
* Consumers must only be aware of the events they consume. A consumer must be agnostic to the producer of an event.
* Publishers are aware that subscribers exists but only in the abstract sense much like an RESTful API is aware that clients exists. The publisher must maintain a certain level of stability in the message bus for its subscribers.









	
	

# Scrap yard
 Publisher must collaborate with subscribers to the degree that enables the subscribers to read events from the message bus but no further.


For systems that demand the highest level of availability each component can be configured in an active-active topology. Systems with lower availability requirements may be configured in an active-pilotlight topology where only the datastore is replicated.