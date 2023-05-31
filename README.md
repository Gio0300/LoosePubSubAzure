# Loosely coupled pub-sub on Azure
In this article we are going to dig into some of the aspects behind loosely coupled pub-sub architectures. We'll spend some time on the concepts b

No claims of resiliency and high availability
		That will be a different article discussing how to implement multi-region active-active pub-sub.

Inbox/Outbox - provide link to article.

Let's start with some definitions to make sure we have a shared understanding of the terms. In particular I am going to make a firm distinction between the terms producer and publisher. These terms are often used interchangeably in high level system designs. But once we get into implementation details the distinction becomes necessary. Later we'll use the same line of thinking to make the distinction between subscriber and consumer.

## Producers & Publishers
Producer - A component from the business layer responsible for creating an event based on business rules. Producing events is strictly a business concern, the producer is divorced from any and all infrastructure related responsibility. Much like the business logic isn't responsible for data storage, we delegate storage to the database. Producers are not responsible for publishing events, that responsibility is delegated to the publisher.

Publisher - A component from the infrastructure layer responsible for making events available to other components of the system.The Publisher sets the terms of the integration. It owns the message bus, the event retention policy, and the event delivery guarantees. The publisher is a commodity, a technical requirement, the publisher doesn't require any business knowledge. How it's implemented is defined by the operating infrastructure. The business logic should not be concerned with how an event is published any more than it's concerned with how the database persists data.

## Reasons to separate the roles
There are many other reasons for separating the roles of producer and publisher. Separating the roles eliminates the need for a distributed transaction between the event store and the message bus. The producer need simply to emit the domain event, adapters (aka services) in the code will marshal the event to the event store in a single transaction. The publisher will eventually publish the event in a separate transaction. With this arrangement the producer is free to operate even when there is an outage in the message bus.

The scaling profile of the producer may be widely different than that of the publisher. Consider an application where the producer is a real-time service that accepts orders. The producer will need to be scaled in direct relation to client demand. Where as the rest of the back-end services may be asynchronous. In this application the publisher may be scaled to provide a fixed throughput corresponding to limitations of the message bus. The opposite may be true in an application where an event kicks off a series of workflows, this type of application is common in the manufacturing industry. A single event may need to be published to more than one message bus. Here the publisher may need to scale at a larger pace than the producer to accommodate the data ingestion capabilities of each message bus.

Producer will need to be updated as the business evolves. On the other hand the publisher is a commodity, it should contain no business logic and thus it should have very little reason to change. Separating the roles allows the producer to be maintained and deployed independently from the the publisher.

## Subscribers & Consumers


It is a widely accepted practice that the business logic should be divorced from the details of the data store. The [object-relational mapping](https://en.wikipedia.org/wiki/Object%E2%80%93relational_mapping) (ORM) industry is built around this very practice. Yet often I see business services taking on the role of publisher.


Define Producer, publisher, subscriber, consumer
		Publisher sets the terms of the integration. It owns the message broker and the data retention policy.
		Subscriber is owned by the consumer. Each consumer is responsible for its own inbox (if needed).
	Why make a distinction between producer and publisher and subscriber and consumer.
		Publishing events and subscribing to events is an infrastructure concern, the business logic shouldn't care how the events are published or obtained. To realize that separation of concern we build distinct components that may be changed and scaled independently.
		Eliminates the need for a distributed transaction (one transaction to the event store and one transaction to the message broker).
		When working with legacy systems that need to be included in an event driven architecture we need to create an adapter in the form of an event publisher which is quite distinct from the producer.
		To help with HA and DR.
	
	