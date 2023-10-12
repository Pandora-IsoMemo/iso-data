CREATE TABLE IF NOT EXISTS {{ tableName }} (
  {{ colDefs }},
  PRIMARY KEY (`source`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DELETE FROM {{ tableName }} WHERE `source` = {{ dbSource }};
