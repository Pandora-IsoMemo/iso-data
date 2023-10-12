DELETE FROM `{{ table }}` where `mappingId` = '{{ mappingId }}' AND `source` not in {{ sources }};
