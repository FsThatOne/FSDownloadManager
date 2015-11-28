//
//  FSDownloadManager.m
//  FSDownloadManager
//
//  Created by FS小一 on 15/11/29.
//  Copyright © 2015年 FSxiaoyi. All rights reserved.
//

#import "FSDownloadManager.h"

@interface FSDownloadManager () <UIAlertViewDelegate>

@property (nonatomic, assign) long long expectedFileLength;

@property (nonatomic, assign) long long localFileLength;

@property (nonatomic, copy) NSString* filePath;

@end

@implementation FSDownloadManager

- (void)downloadFileWithUrlString:(NSString*)urlString SuccessCompletion:(SuccessBlock)Success FailCompletion:(FailBlock)failBlock
{
    [self checkServerFileInfoWithUrlString:urlString];

    [self checkLocalFileInfoWithFilePath:self.filePath];

    if (self.localFileLength && self.localFileLength < self.expectedFileLength) {

        // 断点续传
        FSDownloadOperation* op = [[FSDownloadOperation alloc] init];

        op.urlString = urlString;

        op.blk = Success;

        [op downloadFileWithUrlString:urlString offset:self.localFileLength];

        self.downloadOp = op;
    }

    if (!self.localFileLength || self.localFileLength > self.expectedFileLength) {

        // 移除原有的文件,重新下载
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:NULL];

        // 重新下载
        FSDownloadOperation* op = [[FSDownloadOperation alloc] init];

        op.urlString = urlString;

        op.blk = Success;

        [[[NSOperationQueue alloc] init] addOperation:op];

        self.downloadOp = op;
    }

    if (self.localFileLength == self.expectedFileLength) {

        NSLog(@"文件已经下载完毕!");
    }

    self.localFileLength = 0;
}

+ (instancetype)sharedManager
{
    static id _instance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        _instance = [[self alloc] init];

    });
    return _instance;
}

// 检查本地文件信息
- (void)checkLocalFileInfoWithFilePath:(NSString*)filePath
{
    BOOL isYes = [[NSFileManager defaultManager] fileExistsAtPath:filePath];

    if (isYes) {

        NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];

        NSLog(@"%@", attributes[@"NSFileSize"]);

        self.localFileLength = [attributes fileSize];
    }
}

// 发送同步 HEAD 请求,获取文件信息
- (void)checkServerFileInfoWithUrlString:(NSString*)urlString
{
    NSURL* url = [NSURL URLWithString:urlString];

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];

    request.HTTPMethod = @"HEAD";

    NSURLResponse* response = nil;

    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];

    self.expectedFileLength = response.expectedContentLength;

    self.filePath = [NSString stringWithFormat:@"/Users/likaining/Desktop/%@", response.suggestedFilename];

    NSLog(@"server:%lld", response.expectedContentLength);

    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        //
    //
    //        long long result = response.expectedContentLength/(1000 *1000);
    //
    //        NSString *str = [NSString stringWithFormat:@"文件大小为:%lld MB,确认下载吗?",result];
    //
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:self cancelButtonTitle:@"取消下载" otherButtonTitles:@"确认下载", nil];
    //
    //        [alert show];
    //
    //    });
}

@end
