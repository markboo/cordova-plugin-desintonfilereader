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

@end
