//
//  CDVFileReader.h
//  FileReader
//
//  Created by markboo on 2017/01/17.
//  Copyright (c) 2017年 markboo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

@interface CDVFileReader : CDVPlugin

@property (nonatomic) CDVPluginResult *result;
@property (nonatomic, copy) NSString *callbackId;

/*!
 @method
 @abstract 绑定
 */
- (void) startWork:(CDVInvokedUrlCommand*)command;
- (void) callback:(NSString*)filename;

- (int) readPhoneNumberFormFile: (NSString*) fileNameWithPath;
- (BOOL) removeAllFilesAtDirectory;

@end
