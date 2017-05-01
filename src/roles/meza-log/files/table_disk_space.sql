CREATE TABLE IF NOT EXISTS meza_server_log.disk_space
(
	datetime BIGINT,
	PRIMARY KEY (datetime),
	space_total BIGINT,
	space_used BIGINT
);
