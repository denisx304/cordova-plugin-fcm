#include <sys/types.h>
#include <sys/sysctl.h>

#import "AppDelegate+FCMPlugin.h"

#import <Cordova/CDV.h>
#import "FCMPlugin.h"
#import "Firebase.h"
#import <UserNotifications/UserNotifications.h>

@interface FCMPlugin () {}
@end

@implementation FCMPlugin

static BOOL notificatorReceptorReady = NO;
static BOOL appInForeground = YES;

static NSString *notificationCallback = @"FCMPlugin.onNotificationReceived";
static NSString *tokenRefreshCallback = @"FCMPlugin.onTokenRefreshReceived";
static FCMPlugin *fcmPluginInstance;

+ (FCMPlugin *) fcmPlugin {
    
    return fcmPluginInstance;
}

- (void) ready:(CDVInvokedUrlCommand *)command
{
    NSLog(@"Cordova view ready");
    fcmPluginInstance = self;
    [self.commandDelegate runInBackground:^{
        
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
}

// GET TOKEN //
- (void) getToken:(CDVInvokedUrlCommand *)command 
{
    NSLog(@"get Token");
    [self.commandDelegate runInBackground:^{
        NSString* token = [[FIRInstanceID instanceID] token];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:token];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// UN/SUBSCRIBE TOPIC //
- (void) subscribeToTopic:(CDVInvokedUrlCommand *)command 
{
    NSString* topic = [command.arguments objectAtIndex:0];
    NSLog(@"subscribe To Topic %@", topic);
    [self.commandDelegate runInBackground:^{
        if(topic != nil)[[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/%@", topic]];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:topic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) unsubscribeFromTopic:(CDVInvokedUrlCommand *)command 
{
    NSString* topic = [command.arguments objectAtIndex:0];
    NSLog(@"unsubscribe From Topic %@", topic);
    [self.commandDelegate runInBackground:^{
        if(topic != nil)[[FIRMessaging messaging] unsubscribeFromTopic:[NSString stringWithFormat:@"/topics/%@", topic]];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:topic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) registerNotification:(CDVInvokedUrlCommand *)command
{
    NSLog(@"view registered for notifications");
    
    notificatorReceptorReady = YES;
    NSData* lastPush = [AppDelegate getLastPush];
    if (lastPush != nil) {
        [FCMPlugin.fcmPlugin notifyOfMessage:lastPush];
    }
    
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void) notifyOfMessage:(NSData *)payload
{
    NSString *JSONString = [[NSString alloc] initWithBytes:[payload bytes] length:[payload length] encoding:NSUTF8StringEncoding];
    NSString * notifyJS = [NSString stringWithFormat:@"%@(%@);", notificationCallback, JSONString];
    NSLog(@"stringByEvaluatingJavaScriptFromString %@", notifyJS);
    
    if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:notifyJS];
    } else {
        [self.webViewEngine evaluateJavaScript:notifyJS completionHandler:nil];
    }
}

-(void) notifyOfTokenRefresh:(NSString *)token
{
    NSString * notifyJS = [NSString stringWithFormat:@"%@('%@');", tokenRefreshCallback, token];
    NSLog(@"stringByEvaluatingJavaScriptFromString %@", notifyJS);
    
    if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:notifyJS];
    } else {
        [self.webViewEngine evaluateJavaScript:notifyJS completionHandler:nil];
    }
}

-(void) appEnterBackground
{
    NSLog(@"Set state background");
    appInForeground = NO;
}

-(void) appEnterForeground
{
    NSLog(@"Set state foreground");
    NSData* lastPush = [AppDelegate getLastPush];
    if (lastPush != nil) {
        [FCMPlugin.fcmPlugin notifyOfMessage:lastPush];
    }
    appInForeground = YES;
}

// CANCEL //
- (void) cancel:(CDVInvokedUrlCommand *)command
{
    NSString* email = [command.arguments objectAtIndex:0];
    NSLog(@"FCM Plugin: cancel for %@", email);
    [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray *notifications) {
        NSMutableArray *identifiers = [[NSMutableArray alloc] init];
        
        for(UNNotification *n in notifications) {
            NSString *notificationEmail = n.request.content.categoryIdentifier;
            if ([notificationEmail isEqualToString:email]) {
                [identifiers addObject:n.request.identifier];
            }
        }
        
        [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:identifiers];
    }];
}

// CANCEL ALL //
- (void) cancelAll:(CDVInvokedUrlCommand *)command
{
    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
}

// SET BADGE NUMBER //
- (void) setBadgeNumber:(CDVInvokedUrlCommand *)command
{
	long number = [[command.arguments objectAtIndex:0] intValue];
	[UIApplication sharedApplication].applicationIconBadgeNumber = MAX(number, 0);
}

// DECREMENT BADGE NUMBER //
- (void) decrementBadgeNumber:(CDVInvokedUrlCommand *)command
{
	long number = [[command.arguments objectAtIndex:0] intValue];
	long currentBadge = [UIApplication sharedApplication].applicationIconBadgeNumber;
	[UIApplication sharedApplication].applicationIconBadgeNumber = MAX(currentBadge - number, 0);
}

// CLEAR BADGE NUMBER //
- (void) clearBadgeNumber:(CDVInvokedUrlCommand *)command
{
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

// ADD LOCAL NOTIFICATION //
- (void) addNotification:(CDVInvokedUrlCommand *)command
{
    NSDictionary* payload = [command.arguments objectAtIndex:0];
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    NSDictionary* data = [payload valueForKey:@"data"];
    content.title = [data valueForKey:@"title"];
    content.body = [data valueForKey:@"body"];
    content.sound = [UNNotificationSound defaultSound];
    content.categoryIdentifier = [data valueForKey:@"from"];
    content.badge = [data valueForKey:@"unreadMessagesCount"];
    content.userInfo = payload;
    
    NSString *identifier = [self getUniqueIdentifier];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger: nil];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error in adding local notification: %@",error);
        }
    }];
}

// CHECK IF USER ALLOWED NOTIFICATIONS //
- (void) checkIfUserAllowedNotifications:(CDVInvokedUrlCommand *)command
{
	[[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        BOOL userAllowedNotitications = YES;
        if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
            userAllowedNotitications = NO;
        }
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:userAllowedNotitications];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (BOOL) isUniqueIdentifier:(NSString *)identifier
{
    __block BOOL response = YES;
    [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray *notifications) {
        for(UNNotification *n in notifications) {
            if ([n.request.identifier isEqualToString:identifier]) {
                response = NO;
            }
        }
    }];
    return response;
}

- (NSString*) getIdentifier
{
    NSString *possibleChars = @"0123456789ABCDEF";
    NSMutableString *strResult = [NSMutableString string];
    
    for (int i = 0; i < 8; i ++) {
        char randomChar = [possibleChars characterAtIndex:arc4random_uniform([possibleChars length])];
        [strResult appendFormat:@"%c", randomChar];
    }
    [strResult appendFormat:@"%c", '-'];
    
    for (int i = 0; i < 4; i ++) {
        char randomChar = [possibleChars characterAtIndex:arc4random_uniform([possibleChars length])];
        [strResult appendFormat:@"%c", randomChar];
    }
    [strResult appendFormat:@"%c", '-'];
    
    for (int i = 0; i < 4; i ++) {
        char randomChar = [possibleChars characterAtIndex:arc4random_uniform([possibleChars length])];
        [strResult appendFormat:@"%c", randomChar];
    }
    [strResult appendFormat:@"%c", '-'];
    
    for (int i = 0; i < 4; i ++) {
        char randomChar = [possibleChars characterAtIndex:arc4random_uniform([possibleChars length])];
        [strResult appendFormat:@"%c", randomChar];
    }
    [strResult appendFormat:@"%c", '-'];
    
    for (int i = 0; i < 12; i ++) {
        char randomChar = [possibleChars characterAtIndex:arc4random_uniform([possibleChars length])];
        [strResult appendFormat:@"%c", randomChar];
    }
    
    return strResult;
}

- (NSString*) getUniqueIdentifier
{
    NSString* identifier = [self getIdentifier];
    while (![self isUniqueIdentifier:identifier]) {
        identifier = [self getIdentifier];
    }
    return [self getIdentifier];
}

@end
