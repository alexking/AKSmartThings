
#import <Foundation/Foundation.h>
#import <CocoaHTTPServer/HTTPServer.h>
#import "AKHTTPConnection.h"

@interface AKSmartThings : NSObject <AKHTTPConnectionDelegate> {
    
    int port;
    
    NSDictionary *_defaultEndpoint;
}

// Configuration properties
@property NSString *clientId;
@property NSString *clientSecret;
@property NSString *applicationUrlScheme;
@property (nonatomic) NSString *accessToken;
@property (weak) id delegate;

// Informative properties
@property NSArray *endpoints;

@property NSString *code;

// Internal properties
@property (strong) HTTPServer *server;

// Public methods
- (id) initWithClientId: (NSString *)clientId;
- (void) setPort: (int) portNumber;
- (BOOL) askUserForPermissionUsingClientSecret: (NSString *)clientSecret;

- (void) getJSONFor: (NSString *)method withCallback: (SEL)selector;
- (void) getJSONForURL: (NSString *)url withCallback: (SEL)selector onDelegate: (id)delegate;

// Internal methods
- (NSString *)serverBaseUrl;
- (void) discoverEndpoints;


@end

@protocol AKSmartThingsDelegate <NSObject>
@optional
- (void)handleAccessToken: (NSString *)accessToken;
- (void)handleError: (NSError *)error;
- (void)readyForApiRequests: (AKSmartThings*) sender;

@end