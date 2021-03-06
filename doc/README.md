

# A Kafka client for Erlang and Elixir #

Copyright (c) 2014, 2015 Finexkap, 2015 G-Corp, 2015, 2016, 2017 BotsUnit

__Version:__ 2.2.0

__Authors:__ Gregoire Lejeune ([`gregoire.lejeune@finexkap.com`](mailto:gregoire.lejeune@finexkap.com)), Gregoire Lejeune ([`greg@g-corp.io`](mailto:greg@g-corp.io)), Gregoire Lejeune ([`gregoire.lejeune@botsunit.com`](mailto:gregoire.lejeune@botsunit.com)).

[![Hex.pm version](https://img.shields.io/hexpm/v/kafe.svg?style=flat-square)](https://hex.pm/packages/kafe)
[![Hex.pm downloads](https://img.shields.io/hexpm/dt/kafe.svg?style=flat-square)](https://hex.pm/packages/kafe)
[![License](https://img.shields.io/hexpm/l/kafe.svg?style=flat-square)](https://hex.pm/packages/kafe)
[![Build Status](https://travis-ci.org/G-Corp/kafe.svg?branch=master)](https://travis-ci.org/G-Corp/kafe)

__Version 2.0.0 cause changes in the following APIs :__

* [`kafe:start_consumer/3`](kafe.md#start_consumer-3)

* [`kafe:fetch/3`](kafe.md#fetch-3)


__Kafe__ has been tested with Kafka 0.9 and 0.10

You can also use it with Kafka 0.8 but [`kafe_consumer`](kafe_consumer.md) is not compatible with this version.


### Links ###
* [Apache Kafka](http://kafka.apache.org)
* [Apache Kafka Protocol](https://cwiki.apache.org/confluence/display/KAFKA/A+Guide+To+The+Kafka+Protocol)



### Configuration ###


<table width="100%" border="0" summary="configuration">
<tr><td>brokers</td><td><tt>[{inet:hostname(), inet:port_number()}]</tt></td><td>List of brokers</td><td><tt>[{"localhost", 9092}]</tt></td></tr>
<tr><td>pool_size</td><td><tt>integer()</tt></td><td>Initial connection pool/brocker</td><td><tt>5</tt></td></tr>
<tr><td>chunk_pool_size</td><td><tt>integer()</tt></td><td>Size of new connection pool/brocker</td><td><tt>10</tt></td></tr>
<tr><td>brokers_update_frequency</td><td><tt>integer()</tt></td><td>Frequency (ms) for brokers update</td><td><tt>60000</tt></td></tr>
<tr><td>protocol_timeout</td><td><tt>integer()</tt></td><td>API call timeout</td><td><tt>60000</tt></td></tr>
<tr><td>client_id</td><td><tt>binary()</tt></td><td>Client ID Name</td><td><tt><<"kafe">></tt></td></tr>
<tr><td>api_version</td><td><tt>[{integer(), integer()}] | integer() | auto</tt></td><td>API Version</td><td><tt>auto<sup>*</sup></tt></td></tr>
<tr><td>correlation_id</td><td><tt>integer()</tt></td><td>Correlation ID</td><td><tt>0</tt></td></tr>
<tr><td>socket</td><td><tt>[{sndbuf, integer()}, {recbuf, integer()}, {buffer, integer()}]</tt></td><td>Socker configuration</td><td><tt>[{sndbuf, 4194304}, {recbuf, 4194304}, {buffer, 4194304}]</tt></td></tr>
</table>


<sup>*</sup>
 use `0` with Kafka >= 0.8 < 0.9 ; `auto` with Kafka >= 0.9 < 0.10

Example :

```

[
  {kafe, [
    {brokers, [
      {"localhost", 9092},
      {"localhost", 9093},
      {"localhost", 9094}
    ]},
    {pool_size, 1},
    {chunk_pool_size, 2},
    {brokers_update_frequency, 10000},
    {client_id, <<"kafe">>},
    {api_version, auto},
    {correlation_id, 0},
    {socket, [
      {sndbuf, 4194304},
      {recbuf, 4194304},
      {buffer, 4194304}
    ]},
  ]}
]

```

__Kafe__ use [lager](https://github.com/basho/lager) ; see also how to [configure](https://github.com/basho/lager#configuration) it.


#### Custom API version ####

If you need to, you can specify each version of the protocol APIs. To do so, use a list as value for the `api_version`'s configuration. This list must be a list of tuples where the first element is the api key and the second is the api version.

Example :

```

...
{api_version, [{0, 0}, {0, 1}, {0, 0}, ...]}
...

```


### Create a consumer ###


#### Using a function ####

To create a consumer, create a function with 6 parameters :

```

-module(my_consumer).

-export([consume/6]).

consume(CommitID, Topic, Partition, Offset, Key, Value) ->
  % Do something with Topic/Partition/Offset/Key/Value
  ok.

```

The `consume` function must return `ok` if the message was treated, or `{error, term()}` on error.

Then start a new consumer :

```

...
kafe:start(),
...
kafe:start_consumer(my_group, fun my_consumer:consume/6, Options),
...

```

See [`kafe:start_consumer/3`](kafe.md#start_consumer-3) for the available `Options`.

In the `consume` function, if you didn't start the consumer in autocommit mode (using `before_processing | after_processing` in the `commit` options),
you need to commit manually when you have finished to treat the message. To do so, use [`kafe_consumer:commit/4`](kafe_consumer.md#commit-4).

When you are done with your consumer, stop it :

```

...
kafe:stop_consumer(my_group),
...

```


#### Using the `kafe_consumer_subscriber` behaviour ####

```

-module(my_consumer).
-behaviour(kafe_consumer_subscriber).

-export([init/4, handle_message/2]).
-include_lib("kafe/include/kafe_consumer.hrl").

-record(state, {
               }).

init(Group, Topic, Partition, Args) ->
  % Do something with Group, Topic, Partition, Args
  {ok, #state{}}.

handle_message(Message, State) ->
  % Do something with Message
  % And update your State (if needed)
  {ok, NewState}.

```

Then start a new consumer :

```

...
kafe:start().
...
kafe:start_consumer(my_group, {my_consumer, Args}, Options).
% Or
kafe:start_consumer(my_group, my_consumer, Options).
...

```

To commit a message (if you need to), use [`kafe_consumer:commit/4`](kafe_consumer.md#commit-4).


### Using with Elixir ###

Elixir' users can use `Kafe` and `Kafe.Consumer` instead of `:kafe` and `:kafe_consumer`.

```

defmodule My.Consumer do
  def consume(commit_id, topic, partition, offset, key, value) do
    # Do something with topic/partition/offset/key/value
    :ok
  end
end

defmodule My.Consumer.Subscriber do
  @behaviour Kafe.Consumer.Subscriber
  require Kafe.Records

  def init(group, topic, partition, args) do
    % Do something with group/topic/partition/args
    % and create the state
    {:ok, state}
  end

  def handle_message(message, state) do
    msg = Kafe.Records.message(message)
    % Do something with msg and update (or not) the state
    {:ok, new_state}
  end
end

```

```

...
Kafe.start()
...
Kafe.start_consumer(:my_group, &My.Consumer.consume/6, options)
# or
Kafe.start_consumer(:my_group, {My.Consumer.Subscriber, args}, options)
# or
Kafe.start_consumer(:my_group, My.Consumer.Subscriber, options)
...
Kafe.stop_consumer(:my_group)
...

```


### Metrics ###

To enable metrics :

1/ Add [metrics > 2.2](https://hex.pm/packages/metrics) in your dependencies.

2/ Set `enable_metrics` to true in the `kafe` configuration :

```

{kafe, [
  ...
  {enable_metrics, true},
  ...
]}

```

3/ Adding a metrics module in your configuration :

```

{metrics, [
  {metrics_mod, metrics_folsom}
]}

```

You can choose between [Folsom](https://github.com/folsom-project/folsom) (`{metrics_mod, metrics_folsom}`), [Exometer](https://github.com/Feuerlabs/exometer) (`{metrics_mod, metrics_exometer}`) or [Grapherl](https://github.com/processone/grapherl) (`{metrics_mod, metrics_grapherl}`).

Be sure that's Folsom, Exometer or Grapherl and metrics is started before starting Kafe.

```

application:ensure_all_started(folsom).
application:ensure_all_started(metrics).
application:ensure_all_started(kafe).

```

Metrics are disabled by default.

Kafe offers the following metrics :


<table>
<tr><th>Name</th><th>Type</th><th>Description</th></tr>
<tr><td>kafe_consumer.CONSUMER_GROUP.messages.fetch</td><td>gauge</td><td>Number of received messages on the last fetch for the CONSUMER_GROUP</td></tr>
<tr><td>kafe_consumer.CONSUMER_GROUP.TOPIC.PARTITION.messages.fetch</td><td>gauge</td><td>Number of received messages on the last fetch for the {TOPIC, PARTITION} and CONSUMER_GROUP</td></tr>
<tr><td>kafe_consumer.CONSUMER_GROUP.messages</td><td>counter</td><td>Total number of received messages for the CONSUMER_GROUP</td></tr>
<tr><td>kafe_consumer.CONSUMER_GROUP.TOPIC.PARTITION.messages</td><td>counter</td><td>Total number of received messages for the {TOPIC, PARTITION} and CONSUMER_GROUP</td></tr>
<tr><td>kafe_consumer.CONSUMER_GROUP.TOPIC.PARTITION.duration.fetch</td><td>gauge</td><td>Fetch duration (ms) per message, for the {TOPIC, PARTITION} and CONSUMER_GROUP</td></tr>
<tr><td>kafe_consumer.CONSUMER_GROUP.TOPIC.PARTITION.pending_commits</td><td>gauge</td><td>Number of pending commits, for the {TOPIC, PARTITION} and CONSUMER_GROUP</td></tr>
</table>


You can add a prefix to all metrics by adding a `metrics_prefix` in the `metrics` configuration :

```

{metrics, [
  {metrics_mod, metrics_folsom},
  {metrics_prefix, my_bot}
]}

```


### Build and tests ###

__Kafe__ use [rebar3](http://www.rebar3.org) and [bu.mk](https://github.com/G-Corp/bu.mk). So, you can use :

* `./rebar3 compile` to compile Kafe.

* `./rebar3 eunit` to run tests.

* `./rebar3 ct` to run (integration) tests.

* `./rebar3 edoc` to build documentation.

* `./rebar3 elixir generate_mix` to generate `mix.exs` file.

* `./rebar3 elixir generate_lib` to generate Elixir bindings.


Or

* `make release` Tag and release to hex.pm

* `make integ` Run integration tests

* `make docker-compose.yml` Create docker-compose.yml

* `make docker-start` Start docker

* `make docker-stop` Stop docker

* `make elixir` Generate Elixir bindings (mix.exs and libs)

* `make tests` Run tests

* `make doc` Generate doc

* `make dist` Create a distribution

* `make clean` Clean

* `make distclean` Clean the distribution

* `make info` Display application informations

* `make tag` Create a git tag

* `make local.hex` Install hexfor Mix

* `make local.rebar` Install rebar for Mix

* `make bu-mk` Update bu.mk

* `make help` Show this help.


To run the integration tests, you must start zookeeper and a kafka cluster (3 brokers) and have the following three topics :

* `testone` : replication factor: 1, partitions: 1

* `testtwo` : replication factor: 2, partitions: 2

* `testthree` : replication factor: 3, partitions: 3


You can use the makefile rules `docker-compose.yml` and `docker-start` to help you to create this environment using docker (tested on Linux only).


### API Documentation ###

See [documentation](.)


### Contributing ###
1. Fork it ( https://github.com/G-Corp/kafe/fork )
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request



### Licence ###

kafe is available for use under the following license, commonly known as the 3-clause (or "modified") BSD license:

Copyright (c) 2014, 2015 Finexkap<br />
Copyright (c) 2015, G-Corp<br />
Copyright (c) 2015, 2016 BotsUnit<br />

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.



THIS SOFTWARE IS PROVIDED BY THE AUTHOR `AS IS` AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


## Modules ##


<table width="100%" border="0" summary="list of modules">
<tr><td><a href="kafe.md" class="module">kafe</a></td></tr>
<tr><td><a href="kafe_consumer.md" class="module">kafe_consumer</a></td></tr>
<tr><td><a href="kafe_consumer_subscriber.md" class="module">kafe_consumer_subscriber</a></td></tr></table>

