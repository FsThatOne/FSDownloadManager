//
//  FSDownloadOperation.m
//  FSDownloadManager
//
//  Created by FS小一 on 15/11/29.
//  Copyright © 2015年 FSxiaoyi. All rights reserved.
//

#import "FSDownloadOperation.h"

@interface FSDownloadOperation () <NSURLConnectionDataDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableData* fileData;

// 文件流
@property (nonatomic, strong) NSOutputStream* stream;

@property (nonatomic, assign) long long expectedLength;

@property (nonatomic, assign) long long localLength;

@end

@implementation FSDownloadOperation

- (void)downloadFileWithUrlString:(NSString*)urlString offset:(long long)offset
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        NSURL* url = [NSURL URLWithString:self.urlString];

        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];

        NSString* range = [NSString stringWithFormat:@"bytes=%lld-", offset];

        // 注意,一旦设置 Range http 响应的状态码就会变成 206.
        [request setValue:range forHTTPHeaderField:@"Range"];

        NSURLConnection* conn = [NSURLConnection connectionWithRequest:request delegate:self];

        [conn start];

        self.conn = conn;

        CFRunLoopRun();

    });
}

- (NSMutableData*)fileData
{
    if (!_fileData) {
        _fileData = [NSMutableData data];
    }
    return _fileData;
}

- (void)main
{
    @autoreleasepool
    {

        self.localLength = 0;

        NSURL* url = [NSURL URLWithString:self.urlString];

        NSURLRequest* request = [NSURLRequest requestWithURL:url];

        self.conn = [NSURLConnection connectionWithRequest:request delegate:self];

        [self.conn setDelegateQueue:[[NSOperationQueue alloc] init]];

        // 启动连接
        [self.conn start];

        // 开启运行循环
        CFRunLoopRun();

        [[NSRunLoop currentRunLoop] run];

        NSLog(@"代理方法执行结束之后,就会回到这里!");
    }
}

#pragma NSURLConnectionDataDelegate
// 接收到服务器相应的时候就会调用
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    self.filePath = [NSString stringWithFormat:@"/Users/likaining/Desktop/%@", response.suggestedFilename];

    self.expectedLength = response.expectedContentLength;

    NSOutputStream* stream = [[NSOutputStream alloc] initToFileAtPath:self.filePath append:YES];

    [stream open];

    self.stream = stream;

    NSLog(@"%lld", response.expectedContentLength);
}
// 接收到服务器数据的时候就会调用
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    self.localLength += data.length;

    CGFloat progress = (CGFloat)self.localLength / self.expectedLength;

    if (self.blk) {

        self.blk(progress);
    }

    [self.stream write:data.bytes maxLength:data.length];

    NSLog(@"%@", [NSThread currentThread]);
}

// 数据接收完毕的时候就会调用
- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [self.stream close];
}

// 网络连接错误的时候就会调用
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
}

// 将数据写入沙盒
- (void)writeData:(NSData*)data toFilePath:(NSString*)filePath
{
    NSFileHandle* handle = [NSFileHandle fileHandleForWritingAtPath:filePath];

    if (!handle) {

        [data writeToFile:filePath atomically:YES];
    }
    else {
        [handle seekToEndOfFile];

        [handle writeData:data];

        [handle closeFile];
    }
}

@end
