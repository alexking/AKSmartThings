
#import "AKHTTPConnection.h"
#import "HTTPDataResponse.h"

@implementation AKHTTPConnection

static id <AKHTTPConnectionDelegate> delegate;

+ (void) setDelegate: (id) delegateToSet {
    delegate = delegateToSet;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{

    // Tell our delegate and get our output
    NSString *output = @"";
    
    if ([delegate respondsToSelector: @selector(httpRequest:withParams:)])
    {
        output = [delegate httpRequest: path withParams: [self parseGetParams]];
    }
    
    return [[HTTPDataResponse alloc] initWithData: [output dataUsingEncoding: NSUTF8StringEncoding]];
    
}

@end
