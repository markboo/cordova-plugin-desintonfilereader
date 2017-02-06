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
        //对于错误信息
        NSError *error;
        //创建文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //导入的文件系统默认保存在此目录
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Inbox"];
        //提取文件名称
        NSString *fileNameStr = [url lastPathComponent];
        //合并文件名和目录
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileNameStr];
        
        //NSString *message = [[NSString alloc] initWithFormat:@"应用程序将为你导入文件：\n%@\n并会提取其中的所有手机号码！", [self decodeString:filename]];
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"递信通提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        //[alert show];
        
        //调取JS
        CDVFileReader *filereaderPlugin = [self.viewController.commandDelegate getCommandInstance:@"DesintonFileReader"];
        [filereaderPlugin callback:[self decodeString:fileNameStr]];
        
        NSLog( @"file name: %@", [self decodeString:fileNameStr] );
        NSLog(@"Documentsdirectory: %@", [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error]);

        
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath: filePath];
        NSData *data = [file readDataToEndOfFile];//得到文件,读取到NSDate中
        NSString* aStr = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]; //转换为NSString
        
        NSString *str = aStr;//@"lasdkjflakjsdflj18611291775laskdjflasjd15810728160";
        NSString *phoneRegex = @"((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:phoneRegex options:0 error:nil];
        
        NSArray *matches = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
        if ( matches.count != 0 )
        {
            for( NSTextCheckingResult *result in matches ){
                NSRange matchRange = [result range];
                NSLog( @"%@", [str substringWithRange:matchRange] );
            }
        }
        [file closeFile];
        
        //不保留原始文件，处理删除文件
        if ( [fileManager removeItemAtPath:filePath error:&error] != YES ) {
            NSLog(@"未能删除文件: %@", [error localizedDescription]);
        } else {
            NSLog(@"文件删除成功！");
        }
    }
    return YES;
}

@end
