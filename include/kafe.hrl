-define(DEFAULT_IP, enet:get_loopback()).
-define(DEFAULT_PORT, 9092).
-define(DEFAULT_CLIENT_ID, <<"kafe">>).
-define(DEFAULT_CORRELATION_ID, 0).
-define(DEFAULT_API_VERSION, 0).
-define(DEFAULT_OFFSET, 0).
-define(DEFAULT_BROKER_UPDATE, 60000).

-define(PRODUCE_REQUEST, 0).
-define(FETCH_REQUEST, 1).
-define(OFFSET_REQUEST, 2).
-define(METADATA_REQUEST, 3).
-define(OFFSET_COMMIT_REQUEST, 8).
-define(OFFSET_FETCH_REQUEST, 9).
-define(CONSUMER_METADATA_REQUEST, 10).

-define(DEFAULT_OFFSET_PARTITION, 0).
-define(DEFAULT_OFFSET_TIME, -1).
-define(DEFAULT_OFFSET_MAX_SIZE, 65535).

-define(BITMASK_REQUIRE_ACK, 1).
-define(DEFAULT_PRODUCE_REQUIRED_ACKS, 0).
-define(DEFAULT_PRODUCE_SYNC_TIMEOUT, 5000).
-define(DEFAULT_PRODUCE_PARTITION, 0).

-define(DEFAULT_FETCH_PARTITION, 0).
-define(DEFAULT_FETCH_MAX_BYTES, 1024*1024).
-define(DEFAULT_FETCH_MIN_BYTES, 1).
-define(DEFAULT_FETCH_MAX_WAIT_TIME, 1).

