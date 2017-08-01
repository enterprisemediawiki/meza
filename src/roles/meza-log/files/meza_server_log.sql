CREATE TABLE IF NOT EXISTS meza_server_log.performance (
	datetime BIGINT,
	PRIMARY KEY (datetime),
	loadavg1 FLOAT(3),
	loadavg5 FLOAT(3),
	loadavg15 FLOAT(3),
	memorypercentused FLOAT(4),
	mysql FLOAT(4),
	es FLOAT(4),
	memcached FLOAT(4),
	parsoid FLOAT(4),
	apache FLOAT(4),
	jobs FLOAT(4)
);
