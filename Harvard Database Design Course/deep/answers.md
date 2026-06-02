# From the Deep

In this problem, you'll write freeform responses to the questions provided in the specification.

## Random Partitioning

  Reasons to use this type of partitioning would be the way it is evenly distributed across all partitions, which would mean that all boats receive roughly the same amount of data.

  It is also simple to implement.

  The main reason not to use this would be that it is poor for targeted queries as we have seen, it would be very difficult to find all observations from midnight, because we're forced to search all boats.

## Partitioning by Hour

   The main reason why I'd suggest implementing this type of partition is because we know what partition to search based on the timeframe, meaning it is great for targetted queries.

   However, as we have seen it can occur that most of our data is collected at certain hours so I think that it could mean that some partitions may be overloaded.

## Partitioning by Hash Value

  Just like with random partitioning I think one of the reasons to use this type of partitioning is that it is evenly distributed across all boats.

  Another reason to use it is because very specific querying is easy to do, thanks to the hash value.

  Howewever, range querying would not be suitable, as we would have to search through every single partition.
