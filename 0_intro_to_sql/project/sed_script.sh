#!/usr/bin/bash

terms_to_replace_lower="with as select from where group by sum count numeric join on order by round and create view or limit"
#files_to_update="country_level_detail.sql recommendations.sql create_forestation_view.sql global_situation.sql regional_outlook.sql"
files_to_update=country_level_detail.sql

# echo ${terms_to_replace_lower}
# echo ${terms_to_replace_upper}

for file in ${files_to_update}; do

    for val in ${terms_to_replace_lower}; do
        sed -i "s/\b${val}\b/${val^^}/g" ./${file}
    done
    
done