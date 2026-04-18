so here i will explain how to extract items from xls file, 
- xls files will include items and name of file will be like this {provider name}_catalog.xls
- the column name is the name of the item
- column serial represents serialnumber of item 
- column price is the items price 
- column disc is discribtion ..
- now from column disc we can know the units .. for example if it says cm then Units is centimeter ( or any other metric units just convert to cm or mm )  kg for example is kilogram , and this column includes other disctibtions .. .
- in disc its written in this format [units number if it has kg or cm or etc it tells what are the units .. if its just number then units ] | [how many in stock] | [how its measure and not ] | [more note]

now the task is delete old items in data base and renter those items according to the describtion above in more accurate way. 

also let the admin and provider be able to edit their items, and make an account for provider patara and for each provider we have xls for ..