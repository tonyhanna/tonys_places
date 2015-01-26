#import "LocationManager.h"

@implementation LocationManager

@synthesize locationManager;
@synthesize location;
@synthesize heading;

static LocationManager * _instance;
+ (void)initialize { _instance = [[LocationManager alloc] init]; }
+ (LocationManager *) instance { return _instance; }

- (id) init {
	self = [super init];
	if (self != nil) {
		NSLog(@"Starting location manager");
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self; // send loc updates to myself
        NSLog(@"check LocationManager %d %d", [CLLocationManager locationServicesEnabled], [CLLocationManager headingAvailable]);
#if !TARGET_IPHONE_SIMULATOR
       	if ([CLLocationManager locationServicesEnabled] && [CLLocationManager headingAvailable]) {
            [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
			[locationManager startUpdatingLocation];
			[locationManager startUpdatingHeading];
		} else {
		}
#else
        //dummy location
        //base: 107.652 -6.86106
        [locationManager startUpdatingLocation];
        /*double longitude = 107.652;
        double latitude = -6.86156;
        CLLocation * dummyLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        self.location = dummyLocation;
        [dummyLocation release];
        [NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(dummyLocationUpdate:) userInfo:nil repeats:NO];*/
#endif
	}
	return self;
}

- (void)dealloc 
{
	[self.locationManager release];
    [super dealloc];
}

- (void)dummyLocationUpdate:(NSTimer*)timer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationUpdate" object:self];
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	self.location = newLocation;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"locationUpdate" object:self];				
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	self.heading = newHeading;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"headingUpdate" object:self];		
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{		
	NSLog(@"Location error: %@", [error localizedDescription]);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"locationError" object:self];
}

- (void)addSubscriber:(id)subscriber updateHandler:(SEL)updateSelector
{
	[self addSubscriber:subscriber updateHandler:updateSelector headingHandler:NULL errorHandler:NULL];}

- (void)addSubscriber:(id)subscriber updateHandler:(SEL)updateSelector headingHandler:(SEL)headingSelector
{
	[self addSubscriber:subscriber updateHandler:updateSelector headingHandler:headingSelector errorHandler:NULL];
}

- (void)addSubscriber:(id)subscriber updateHandler:(SEL)updateSelector headingHandler:(SEL)headingSelector errorHandler:(SEL)errorSelector;
{
	[[NSNotificationCenter defaultCenter] addObserver:subscriber selector:updateSelector name:@"locationUpdate" object:self];
	if (headingSelector != NULL)
		[[NSNotificationCenter defaultCenter] addObserver:subscriber selector:headingSelector name:@"headingUpdate" object:self];
	if (errorSelector != NULL)
		[[NSNotificationCenter defaultCenter] addObserver:subscriber selector:errorSelector name:@"locationError" object:self];
    
    if (![CLLocationManager locationServicesEnabled] || ![CLLocationManager headingAvailable]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"locationUpdate" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"headingUpdate" object:self];
    }

}

- (void)removeSubscriber:(id)subscriber
{
	[[NSNotificationCenter defaultCenter] removeObserver:subscriber];
}

@end
