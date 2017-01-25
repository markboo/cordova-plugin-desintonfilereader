//
//  AppDelegate+DesintonNotification.h
//  Desinton
//
//  Created by jingangbao on 2016/12/16.
//
//

#import "AppDelegate.h"

@interface AppDelegate (notification)
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
@end
