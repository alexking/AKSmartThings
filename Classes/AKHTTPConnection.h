
#import <Foundation/Foundation.h>
#import "HTTPConnection.h"

@interface AKHTTPConnection : HTTPConnection

+ (void) setDelegate: (id) delegateToSet;

@end

@protocol AKHTTPConnectionDelegate <NSObject>
@optional
- (NSString *)httpRequest: (NSString *)path withParams: (NSDictionary *)params;
@end