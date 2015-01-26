
#import "URLLoader.h"
#import "CallbackHandler.h"

@implementation URLLoader

@synthesize label, response;

- (void)dealloc
{
    [request release];
    [response release];
	[mutData release];
	[connection release];
	[loadTargets release];
	[super dealloc];
}

static int loadingCount = 0;

+ (void)incrementLoadingCount
{
    loadingCount++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = (loadingCount >  0);
}

+ (void)decrementLoadingCount
{
    loadingCount--;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = (loadingCount >  0);
}

- (id)initWithURL:(NSURL *)aURL 
{
    self = [super init];
    if (self != nil){
        NSURL * url = aURL;
        loadTargets = [[NSMutableArray alloc] init];
        // SET UP THE REQUEST
        request = [[NSURLRequest alloc] initWithURL:url];
    }
	return self;
}

- (id)initWithURLString:(NSString *)aString
{
    self = [super init];
    if (self != nil){
        NSURL * url = [NSURL URLWithString:[aString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        loadTargets = [[NSMutableArray alloc] init];
        // SET UP THE REQUEST
        request = [[NSURLRequest alloc] initWithURL:url];
    }
    return self;
}

- (id)initWithRequest:(NSURLRequest *)aRequest
{
    self = [super init];
    if (self != nil){
        loadTargets = [[NSMutableArray alloc] init];
        request = [aRequest retain];
    }
    return self;
}

- (NSURL*)url
{
    return request.URL;
}

- (NSData*)data
{
    return mutData;
}

- (NSString*)dataAsString
{
    return [[NSString alloc] initWithData:mutData encoding:NSUTF8StringEncoding];
}

- (void)load
{
	// SHOW NETWORK INDICATOR
	
    [URLLoader incrementLoadingCount];
	
	// NEW MUT DATA
	
	mutData = [[NSMutableData alloc] init];
    
	// SET UP THE CONNECTION

	connection = [[NSURLConnection alloc] initWithRequest:request
												 delegate:self];
	
	
}

- (void)addTarget:(id)target onLoad:(SEL)selector
{
	CallbackHandler * handler = [[CallbackHandler alloc] init];
	handler.object = target;
	handler.selector = selector;
	[loadTargets addObject:handler];
	[handler release];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [URLLoader decrementLoadingCount];
    NSLog(@"[URLLoader] connection fail %@", error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
    [response = aResponse retain];
}

- (void)connection:(NSURLConnection *)connection
	didReceiveData:(NSData *)data
{
	
	// APPEND THE DATA
	
	[mutData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
	// ONCE LOADED HIDE NETWORK INDICATOR
	
    [URLLoader decrementLoadingCount];
	
	[self retain];
	for (int i=0; i<loadTargets.count; i++){
		CallbackHandler * handler = (CallbackHandler*)[loadTargets objectAtIndex:i];
		[handler.object performSelector:handler.selector withObject:self];
	}
    [self release];

}

@end