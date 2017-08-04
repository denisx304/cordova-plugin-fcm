#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

@interface FCMPlugin : CDVPlugin
{
    //NSString *notificationCallBack;
}

+ (FCMPlugin *) fcmPlugin;
- (void)ready:(CDVInvokedUrlCommand*)command;
- (void)getToken:(CDVInvokedUrlCommand*)command;
- (void)subscribeToTopic:(CDVInvokedUrlCommand*)command;
- (void)unsubscribeFromTopic:(CDVInvokedUrlCommand*)command;
- (void)registerNotification:(CDVInvokedUrlCommand*)command;
- (void)notifyOfMessage:(NSData*) payload;
- (void)notifyOfTokenRefresh:(NSString*) token;
- (void)appEnterBackground;
- (void)appEnterForeground;
- (void)cancel:(CDVInvokedUrlCommand*)command;
- (void)cancelAll:(CDVInvokedUrlCommand*)command;
- (void)setBadgeNumber:(CDVInvokedUrlCommand *)command;
- (void)decrementBadgeNumber:(CDVInvokedUrlCommand*)command;
- (void)clearBadgeNumber:(CDVInvokedUrlCommand*)command;
- (void)addNotification:(CDVInvokedUrlCommand*)command;
- (BOOL)isUniqueIdentifier:(NSString*)identifier;
- (NSString*)getIdentifier;
- (NSString*)getUniqueIdentifier;

@end
