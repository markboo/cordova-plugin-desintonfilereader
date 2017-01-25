//
//  AppDelegate+DesintonNotification.m
//  Desinton
//
//  Created by jingangbao on 2016/12/16.
//
//

#import "AppDelegate+DesintonFileReader.h"
#import <objc/runtime.h>
#import "CDVFileReader.h"

@implementation AppDelegate (notification)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(init);
        SEL swizzledSelector = @selector(pushPluginSwizzledInit);
        
        Method original = class_getInstanceMethod(class, originalSelector);
        Method swizzled = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzled),
                        method_getTypeEncoding(swizzled));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(original),
                                method_getTypeEncoding(original));
        } else {
            method_exchangeImplementations(original, swizzled);
        }
    });
}

- (AppDelegate *)pushPluginSwizzledInit
{
    [[NSNotificationCenter defaultCenter]
             addObserver:self
             selector:@selector(applicationDidBecomeActive:)
             name:UIApplicationDidBecomeActiveNotification
             object:nil]; //监听是否重新进入程序程序.
    
    return [self pushPluginSwizzledInit];
}

//URLEncode
-(NSString*)encodeString:(NSString*)unencodedString{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

//URLDEcode
-(NSString *)decodeString:(NSString*)encodedString
{
    NSString *decodedString = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                    (__bridge CFStringRef)encodedString,CFSTR(""),
                                                                                                                    CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (url != nil) {
        NSString *path = [url absoluteString];
        NSMutableString *string = [[NSMutableString alloc] initWithString:path];

        NSArray *parts = [string componentsSeparatedByString:@"/"];
        NSString *filename = [parts lastObject];
        
        if ([path hasPrefix:@"file://"]) {
            [string replaceOccurrencesOfString:@"file://" withString:@"" options:NSCaseInsensitiveSearch  range:NSMakeRange(0, path.length)];
        }
        
        NSString *message = [[NSString alloc] initWithFormat:@"应用程序将为你导入文件：\n%@\n并会提取其中的所有手机号码！", [self decodeString:filename]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"递信通提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        
        CDVFileReader *filereaderPlugin = [self.viewController.commandDelegate getCommandInstance:@"DesintonFileReader"];
        [filereaderPlugin callback:[self decodeString:filename]];
        
        NSLog( @"file name: %@", [self decodeString:filename] );
    }
    return YES;
}

@end
