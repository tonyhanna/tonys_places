
@interface URLLoader : NSObject {
	
	NSURLConnection * connection;
    
    NSURLRequest * request;
    
    NSURLResponse * response;
	
	NSMutableData * mutData;
	
	NSString * label;
	
	NSMutableArray * loadTargets;
	
}

@property ( nonatomic, retain ) NSString * label;
@property (nonatomic, readonly, retain) NSURLResponse * response;

- (id)initWithURL:(NSURL *)aURL;
- (id)initWithURLString:(NSString *)aString;
- (id)initWithRequest:(NSURLRequest *)aRequest;
- (void)load;
- (void)addTarget:(id)target onLoad:(SEL)selector;
- (NSURL*)url;
- (NSData*)data;
- (NSString*)dataAsString;

@end
