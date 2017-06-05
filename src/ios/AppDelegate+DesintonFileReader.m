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

static const char* kFileNameWithPathPropertyKey = "kFrkFileNameWithPathPropertyKeyiendsPropertyKey";

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

- (NSString*) fileNameWithPath {
    return objc_getAssociatedObject(self, kFileNameWithPathPropertyKey);
}

- (void)setFileNameWithPath:(NSString *)fileNameWithPath {
    objc_setAssociatedObject(self, kFileNameWithPathPropertyKey, fileNameWithPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
        //对于错误信息
        //NSError *error;
        //创建文件管理器
        //NSFileManager *fileManager = [NSFileManager defaultManager];
        //导入的文件系统默认保存在此目录
        //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Inbox"];
        //提取文件名称
        NSString *fileName = [url lastPathComponent];
        self.fileNameWithPath = url;
        //合并文件名和目录
        //NSString *fileNameWithPath = [documentsDirectory stringByAppendingPathComponent:fileName];
        //fileNameWithPath = [documentsDirectory stringByAppendingPathComponent:fileName];
        
        NSString *message = [[NSString alloc] initWithFormat:@"应用程序将为你导入文件：\n%@\n并会提取其中的所有手机号码！", [self decodeString:fileName]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"递信通提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
    return YES;
}

// 在这里处理UIAlertView中的按钮被单击的事件
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog( @"buttonIndex is : %li", (long)buttonIndex );
    
    switch (buttonIndex) {
        case 0:{ //点击取消按钮处理
            CDVFileReader *filereaderPlugin = [self.viewController.commandDelegate getCommandInstance:@"DesintonFileReader"];
            [filereaderPlugin removeAllFilesAtDirectory];
        }break;
        
        case 1:{ //点击确定按钮处理
            //对于错误信息
            NSError *error;
            //创建文件管理器
            NSFileManager *fileManager = [NSFileManager defaultManager];
            //导入的文件系统默认保存在此目录
            NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Inbox"];
            //提取文件名称
            NSString *fileName = [self.fileNameWithPath lastPathComponent];
            //合并文件名和目录
            NSString *fileNameWithPath = [documentsDirectory stringByAppendingPathComponent:fileName];
            
            //调取JS
            CDVFileReader *filereaderPlugin = [self.viewController.commandDelegate getCommandInstance:@"DesintonFileReader"];
            [filereaderPlugin callback:[self decodeString:fileNameWithPath]];
            
            NSLog( @"file name: %@", [self decodeString:fileNameWithPath] );
            NSLog(@"Documentsdirectory: %@", [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error]);
            
            [filereaderPlugin readPhoneNumberFormFile:fileNameWithPath];
        }break;
        
        default:
        break;
    }
}

@end
