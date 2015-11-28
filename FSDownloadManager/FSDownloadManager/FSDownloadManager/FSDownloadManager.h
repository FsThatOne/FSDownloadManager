//
//  FSDownloadManager.h
//  FSDownloadManager
//
//  Created by FS小一 on 15/11/29.
//  Copyright © 2015年 FSxiaoyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FSDownloadOperation.h"

typedef void (^SuccessBlock)(float progress);
typedef void (^FailBlock)(NSError* error);
@interface FSDownloadManager : NSObject

@property (nonatomic, strong) FSDownloadOperation* downloadOp;

+ (instancetype)sharedManager;

- (void)downloadFileWithUrlString:(NSString*)urlString SuccessCompletion:(SuccessBlock)Success FailCompletion:(FailBlock)failBlock;

- (void)checkLocalFileInfoWithFilePath:(NSString*)filePath;

// 检查服务器端存储的文件信息
- (void)checkServerFileInfoWithUrlString:(NSString*)urlString;

@end
