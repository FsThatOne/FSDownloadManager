//
//  FSDownloadOperation.h
//  FSDownloadManager
//
//  Created by FS小一 on 15/11/29.
//  Copyright © 2015年 FSxiaoyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^SuccessBlock)(float progress);
typedef void (^FailBlock)(NSError* error);

@interface FSDownloadOperation : NSObject

// 网络连接
@property (nonatomic, strong) NSURLConnection* conn;

// 需要下载的文件地址
@property (nonatomic, copy) NSString* urlString;

// 文件在本地存储的路径
@property (nonatomic, copy) NSString* filePath;

@property (nonatomic, copy) SuccessBlock blk;

- (void)downloadFileWithUrlString:(NSString*)urlString offset:(long long)offset;

@end
