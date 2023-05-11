IF (EXISTS (SELECT *
              FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_NAME = `{{ tableName }}`))
DELETE FROM `{{ tableName }}` WHERE `source` = `{{ dbSource }}` ELSE
CREATE TABLE IF NOT EXISTS `{{ tableName }}` ({{ colDefs }}, PRIMARY KEY (`source`,`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
