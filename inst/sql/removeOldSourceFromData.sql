DELETE FROM `{{ mappingId }}_data` where `source` not in {{ sources }};
