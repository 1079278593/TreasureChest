#import "HTTPDataResponse.h"
#import "HTTPLogging.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_OFF; // | HTTP_LOG_FLAG_TRACE;


@implementation HTTPDataResponse

- (id)initWithData:(NSData *)dataParam
{
	if((self = [super init]))
	{
		
		
		offset = 0;
		data = dataParam;
	}
	return self;
}

- (void)dealloc
{
	
	
}

- (UInt64)contentLength
{
	UInt64 result = (UInt64)[data length];
	
	NSLog(@"%@[%p]: contentLength - %llu", THIS_FILE, self, result);
	
	return result;
}

- (UInt64)offset
{
	
	
	return offset;
}

- (void)setOffset:(UInt64)offsetParam
{
	NSLog(@"%@[%p]: setOffset:%lu", THIS_FILE, self, (unsigned long)offset);
	
	offset = (NSUInteger)offsetParam;
}

- (NSData *)readDataOfLength:(NSUInteger)lengthParameter
{
	NSLog(@"%@[%p]: readDataOfLength:%lu", THIS_FILE, self, (unsigned long)lengthParameter);
	
	NSUInteger remaining = [data length] - offset;
	NSUInteger length = lengthParameter < remaining ? lengthParameter : remaining;
	
	void *bytes = (void *)([data bytes] + offset);
	
	offset += length;
	
	return [NSData dataWithBytesNoCopy:bytes length:length freeWhenDone:NO];
}

- (BOOL)isDone
{
	BOOL result = (offset == [data length]);
	
	NSLog(@"%@[%p]: isDone - %@", THIS_FILE, self, (result ? @"YES" : @"NO"));
	
	return result;
}

@end
