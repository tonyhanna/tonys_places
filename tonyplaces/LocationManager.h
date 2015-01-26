
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	CLLocation * location;
	CLHeading * heading;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) CLHeading *heading;

- (void)addSubscriber:(id)subscriber updateHandler:(SEL)updateSelector headingHandler:(SEL)headingSelector errorHandler:(SEL)errorHandler;
- (void)addSubscriber:(id)subscriber updateHandler:(SEL)updateSelector;
- (void)addSubscriber:(id)subscriber updateHandler:(SEL)updateSelector headingHandler:(SEL)headingSelector;

- (void)removeSubscriber:(id)subscriber;

+ (LocationManager*) instance;

@end