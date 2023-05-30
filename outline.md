Intro

	Define Producer, publisher, subscriber, consumer
		Publisher sets the terms of the integration. It owns the message broker and the data retention policy.
		Subscriber is owned by the consumer. Each consumer is responsible for its own inbox (if needed).
	Why make a distinction between producer and publisher and subscriber and consumer.
		Publishing events and subscribing to events is an infrastructure concern, the business logic shouldn't care how the events are published or obtained. To realize that separation of concern we build distinct components that may be changed and scaled independently.
		Eliminates the need for a distributed transaction (one transaction to the event store and one transaction to the message broker).
		When working with legacy systems that need to be included in an event driven architecture we need to create an adapter in the form of an event publisher which is quite distinct from the producer.
		To help with HA and DR.
	No claims of resiliency and high availability
		That will be a different article discussing how to implement multi-region active-active pub-sub.
	Inbox/Outbox - provide link to article.

	
Components

	Producer: Web API 

	Entity Store: Cosmos
	
	Event Store Cosmos (Transactional Outbox pattern).
		Describe three patterns
			Unit of work (Entity + Event) with Transactional Outbox
			Entity First with change feed event producer. 
				Adapting a legacy system into an EDA.
			Event First with change feed read model maintainer
				Pure event driven architecture with specialized read models
			Draw a sequence diagram for each.
		For this article we'll use Transactional Outbox
			
	Publisher - Azure Function reads change feed  and pushes to event hub. 
		The AF change feed trigger auto scales and auto manages the partition ownership. I need to figure out how the trigger assigns partitions to any given instances. Does it create a 1:1 mapping between Cosmos physical partitions and AF instances? Or does the trigger have its own partition assignment heuristics, perhaps based on the length of the change feed, the throughput of the change feed or the throughput of the function instance? This would be a good bonus detail to include the article
		
		Checkpoint store in azure storage
		
	Subscriber - Azure functions - inbox pattern
		Check point in Azure Storage
		
	Inbox Store
		Describe multiple approaches
			All-in-one Subscriber + Consumer - read and process in one move - Risky for the consumer because if the message broker is unavailable so is the consumer.
				Good option for a real-time streaming, game leaderboard.
			Message broker - Service Bus or Event Hubs - Built in message broker feature. 
				Fan out
				Competing consumer
				Guaranteed single processor w/Service Bus
				Session State
					Poison pill
				-- No built-in geo-replication (yet)
			Warn about using a database (cosmos or SQL) 
				Cosmos DB - Consumer subscribes to change feed - reliable and guaranteed at least once, easy to implement geo-replication but no built-in message broker features and semantics.
					DLQ
					Metrics (number of messages in queue, throughput)
					Message Bus Events (new event in queue without listener)
					Insights
					Session State
					Distributed tracing context
				Databases write to a log first before persisting the entity records. Might as well skip the entity record and stick with a log based data store like a message broker.
		For this article we'll use Service Bus
	
	Consumer
		Azure Function
		
	 
	
