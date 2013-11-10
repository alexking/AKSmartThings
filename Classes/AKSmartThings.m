
#import "AKSmartThings.h"

@implementation AKSmartThings

- (id) initWithClientId: (NSString *)clientId {
    self = [super init];
    
    if (self != nil) {
       
        self.clientId = clientId;
        
    }
    
    return self;
}

// Set an access token
- (void) setAccessToken:(NSString *)accessToken
{
    _accessToken = accessToken;
    
    [self discoverEndpoints];
}

- (void) discoverEndpoints
{
    
    NSString *url = [NSString stringWithFormat: @"/api/smartapps/endpoints/%@", self.clientId];
    
    [self getJSONForURL: url withCallback: @selector(discoveredEndpoints:) onDelegate: self];
    
}

- (void) discoveredEndpoints: (id) endpoints
{
    self.endpoints = endpoints;
    
    // Inform our delegate that it can make API calls now
    if ([self.delegate respondsToSelector: @selector(readyForApiRequests:)]) {
        
        [self.delegate readyForApiRequests: self];
        
    }
    
}

- (NSDictionary *) defaultEndpoint
{
    // Default to the first endpoint we find
    if (_defaultEndpoint == nil) {
        return [self.endpoints lastObject];
    }
    
    return _defaultEndpoint;
}

- (void) setDefaultEndpoint: (NSDictionary *)endpoint
{
    _defaultEndpoint = endpoint;
}

- (NSString *)serverBaseUrl
{
    return [NSString stringWithFormat: @"http://localhost:%d", port];
}

/*! Ask the user for permission to things */
- (BOOL) askUserForPermissionUsingClientSecret: (NSString *)clientSecret
{

    self.clientSecret = clientSecret;
    
    // Default Port
    if (!port) {
        port = 2323;
    }
    
    // We need to be able to handle connections
    [AKHTTPConnection setDelegate: self];
    
    // Setup the server
    self.server = [[HTTPServer alloc] init];
    
    [self.server setConnectionClass: [AKHTTPConnection class]];
    [self.server setPort: port];
    
    NSError *httpError;
    [self.server start: &httpError];
    
    // Check if there was an error starting the server 
    if (httpError) {
        return NO; 
    }
    
    // Start the process
    NSString *endpointFormat = @"https://graph.api.smartthings.com/oauth/authorize?response_type=code&client_id=%@&redirect_uri=%@&scope=app";
    NSURL *authorizeEndpoint = [NSURL URLWithString: [NSString stringWithFormat: endpointFormat, self.clientId, [self serverBaseUrl]]];
    
    return [[NSWorkspace sharedWorkspace] openURL: authorizeEndpoint];
    
}

- (NSString *) httpRequest: (NSString *)path withParams:(NSDictionary *)params
{
    
    // Check for a code
    NSString *ourCode = [params objectForKey: @"code"];
    if (ourCode) {
        
        // We have a code, let's note it for later
        self.code = ourCode;
        
        // Continue with the authorization
        [self authorizeWithCode: ourCode];
        
        // Lets close the window and optionally redirect them back to the app
        NSString *redirectTo;
        if (self.applicationUrlScheme)
        {
            redirectTo = [NSString stringWithFormat: @"window.location = '%@://';", self.applicationUrlScheme];
        }
        
        return [NSString stringWithFormat: @"<script>window.onload = function() { %@ %@ }</script>",
                redirectTo, @"setTimeout(function() { open(location, '_self').close(); }, 100);"];
        
    }

    // Default to OK
    return @"OK";
    
}

- (void) authorizeWithCode: (NSString *)code {
    
    // Endpoint to authorize at
    NSString *endpointFormat = @"https://graph.api.smartthings.com/oauth/token?grant_type=authorization_code&client_id=%@&client_secret=%@&redirect_uri=%@&code=%@&scope=app";
    
    // Form the URL
    NSURL *endpointUrl = [NSURL URLWithString: [NSString stringWithFormat: endpointFormat, self.clientId, self.clientSecret, [self serverBaseUrl], self.code]];
    
    // Call the URL
    NSString *result = [NSString stringWithContentsOfURL: endpointUrl encoding: NSUTF8StringEncoding error: nil];
    
    // Parse the JSON
    NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData: [result dataUsingEncoding: NSUTF8StringEncoding]
                                                               options: 0
                                                                 error: nil];
    // Note the access code
    self.accessToken = [resultJSON objectForKey: @"access_token"];

    // Inform our delegate that there in authorization code to handle
    if ([self.delegate respondsToSelector: @selector(handleAccessToken:)])
    {
        
        [self.delegate handleAccessToken: self.accessToken];
        
    }
    
}

- (void) getJSONForURL: (NSString *)url withCallback: (SEL)selector
{
    [self getJSONForURL: url withCallback:selector onDelegate: self.delegate];
}

- (void) getJSONForURL: (NSString *)url withCallback: (SEL)selector onDelegate: (id)delegate
{
    
    NSURL *actionUrl = [NSURL URLWithString: [NSString stringWithFormat: @"https://graph.api.smartthings.com%@?access_token=%@", url, self.accessToken]];
    NSLog(@"%@", actionUrl);
    NSURLRequest *actionRequest = [[NSURLRequest alloc] initWithURL: actionUrl];
 
    [NSURLConnection sendAsynchronousRequest: actionRequest
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        // Get the string
        NSString *moreJSON = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        
        // Get the JSON
        id jsonObject = [NSJSONSerialization JSONObjectWithData: [moreJSON dataUsingEncoding: NSUTF8StringEncoding]
                                                        options: 0
                                                          error: nil];
        
        // Send it to our selector
        if ([delegate respondsToSelector: selector]) {
            [delegate performSelector: selector withObject: jsonObject];
        }
        
    }];

}

/*! Make an API call to method to an endpoint */
- (void) getJSONFor: (NSString *)method AtEndpoint: (NSDictionary *)endpoint withCallback: (SEL)selector
{
    
    NSString *itemsUrl = [NSString stringWithFormat: @"%@/%@", [endpoint objectForKey: @"url"], method];
    [self getJSONForURL: itemsUrl withCallback: selector];
    
}

/*! Make the same API call the default endpoint */
- (void) getJSONFor: (NSString *)method withCallback: (SEL)selector
{
    [self getJSONFor: method AtEndpoint: [self defaultEndpoint] withCallback: selector];
}


- (void) setPort: (int) portNumber
{
    port = portNumber;
}


@end
