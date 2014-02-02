mysql_php_ios_json
==================

Sync mysql database using php and json to an ios application

cities.sql
==================

Can use this file to create a table inside a database

cities.php
==================

This php is used to connected to the database and convert data to json format. You should put this on your
host. Fiilled the detail of your mysql database:

	$host = "**"; //Your database host server
	$db = "**"; //Your database name
	$user = "**"; //Your database user
	$pass = "**"; //Your password

Change the query here if you want to query something else, line 31:

	$query = "SELECT * FROM cities";

JSON_test project
==================

Refer to AppDelegate.m retrieveData methond to see how to convert json data. Change dataRetrievalURL inside AppDelegate.m
line 12 to url of your php:

	#program mark fill in your url of the php file 
	#define dataRetrievalURL @"your php url"

retriveData:
	
	- (void) retrieveData {
	    NSURL *url = [NSURL URLWithString:dataRetrievalURL];
	    NSData *data = [NSData dataWithContentsOfURL:url];
	    
	    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
	    
	    NSLog(@"The size of json is %d", [json count]);
	    
	    //set up cities array
	    //NSMutableArray *cities = [[NSMutableArray alloc] init];
	    for (int i = 0; i < json.count; i++) {
	        NSDictionary *row = [json objectAtIndex:i];
	        NSLog(@"id: %@, name:%@, state:%@, population:%@, country:%@", [row objectForKey:@"id"], [row objectForKey:@"cityName"], [row objectForKey:@"cityState"], [row objectForKey:@"cityPopulation"], [row objectForKey:@"country"]);
	    }
	}