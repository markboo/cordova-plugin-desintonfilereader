//
//  CDVFileReader.m
//  FileReader
//
//  Created by markboo on 2017/01/17.
//  Copyright (c) 2017年 markboo. All rights reserved.
//

#import <Cordova/CDV.h>
#import "CDVFileReader.h"

@interface CDVFileReader () {}
@end

@implementation CDVFileReader

@synthesize callbackId;

/*!
 @method
 @abstract 开始工作
 */
- (void)startWork:(CDVInvokedUrlCommand*)command
{
    //初始化持久callbackId
    self.callbackId = command.callbackId;

    if( command.arguments.count ) {
        NSString* appkey = [command.arguments objectAtIndex:0];
        NSLog( @"Command Arguments: %@", appkey );
    }
}

/*!
 @method
 @abstract 回调函数
 */
- (void) callback:(NSString*)filename
{
    //NSString* message = [NSString stringWithFormat:@"如果看到这句来自Desinton文件读取插件的返回信息，可以证实插件被正确调用！"];
    
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:filename];
    //允许多次回调
    [commandResult setKeepCallbackAsBool:YES];
    
    [self.commandDelegate sendPluginResult:commandResult callbackId:self.callbackId];
}

/*!
 @method
 @abstract 提取文件中手机号号码
 */
- (int) readPhoneNumberFormFile: (NSString*) fileNameWithPath
{
    int line_count = 0;
    
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath: fileNameWithPath];
    NSData *data = [file readDataToEndOfFile];//得到文件,读取到NSDate中
    NSString *str = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]; //转换为NSString
    NSString *phoneRegex = @"((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:phoneRegex options:0 error:nil];
    NSArray *matches = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    
    if ( matches.count != 0 )
    {
        for( NSTextCheckingResult *result in matches ){
            NSRange matchRange = [result range];
            NSLog( @"%@", [str substringWithRange:matchRange] );
            line_count++;
        }
    }
    [file closeFile];
    
    return line_count;
}

/*!
 @method
 @abstract 删除目录中所有文件
 */
- (BOOL) removeAllFilesAtDirectory
{
    //对于错误信息
    NSError *error;
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //导入的文件系统默认保存在此目录
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Inbox"];

    //循环删除目录中所有文件
    BOOL isExist = [fileManager fileExistsAtPath:documentsDirectory];
    if (isExist){
        NSEnumerator *childFileEnumerator = [[fileManager subpathsAtPath:documentsDirectory] objectEnumerator];
        NSString *tempfileName = @"";
        while ((tempfileName = [childFileEnumerator nextObject]) != nil){
            NSString* fileAbsolutePath = [documentsDirectory stringByAppendingPathComponent:tempfileName];
            NSLog( @"file name: %@", fileAbsolutePath );
            //不保留原始文件，处理删除文件
            if ( [fileManager removeItemAtPath:fileAbsolutePath error:&error] != YES ) {
                NSLog(@"未能删除文件: %@", [error localizedDescription]);
            } else {
                NSLog(@"文件删除成功！");
            }
        }
    }
    return YES;
}

@end
