//
//  HWDownLoader.m
//  HWDownLoader_Example
//
//  Created by 袁海文 on 2019/4/12.
//  Copyright © 2019年 wozaizhelishua. All rights reserved.
//

#import "HWDownLoader.h"
#import "NSString+Hash.h"

// 获取Cache，文件保存在此处
#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
// 存储下载信息字典的路径（caches），该字典的value也是一个字典，存储了文件路径和总长度（文件路径用于删除文件，文件总长度用于判断是否已经全部下完）
#define HWDownLoadInfoPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"downLoadInfo.hw"]

@interface HWDownLoader()<NSURLSessionDataDelegate>
/**下载地址*/
@property (nonatomic, strong) NSURL *url;
/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDataTask *task;
/** session */
@property (nonatomic, strong) NSURLSession *session;
/** 写文件的流对象 */
@property (nonatomic, strong) NSOutputStream *stream;
/** 文件的总长度 */
@property (nonatomic, assign) NSInteger totalLength;
/**
 文件名（沙盒中的文件名）
 */
@property (nonatomic, copy) NSString *filename;
// 文件的存放路径（caches）
@property (nonatomic, copy) NSString *fileFullpath;
// 文件的已下载长度
@property (nonatomic, assign) NSInteger downloadLength;

/**获得下载文件大小的回调*/
@property (nonatomic, copy) void(^downLoadInfoBlock)(long long totalSize);
/**更新进度的回调*/
@property (nonatomic, copy) void(^progressBlock)(float progress);
/**state改变的回调*/
@property (nonatomic, copy) void(^stateChangeBlock)(HWDownLoadState state);
/**下载成功的回调*/
@property (nonatomic, copy) void(^successBlock)(NSString *filePath);
/**下载失败的回调*/
@property (nonatomic, copy) void(^failedBlock)(NSError *error);
@end

@implementation HWDownLoader
#pragma mark - 私有方法
- (NSOutputStream *)stream
{
    if (!_stream) {
        _stream = [NSOutputStream outputStreamToFileAtPath:self.fileFullpath append:YES];
        // 存储文件路径字典到沙盒
        NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:HWDownLoadInfoPath];
        if (infoDict == nil) infoDict = [NSMutableDictionary dictionary];
        
        NSMutableDictionary *info = infoDict[self.filename];
        if (info == nil) info = [NSMutableDictionary dictionary];
        info[@"path"] = self.fileFullpath;
        infoDict[self.filename] = info;
        [infoDict writeToFile:HWDownLoadInfoPath atomically:YES];
    }
    return _stream;
}
- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}
-(NSURLSessionDataTask *)task{
    if (!_task) {
        
        //判断文件是否已经下载过
        NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:HWDownLoadInfoPath];
        
        NSMutableDictionary *info = infoDict[self.filename];
        
        NSInteger totalLength = [info[@"totalLength"] integerValue];
        
        if (totalLength && self.downloadLength == totalLength) {
            NSLog(@"----文件已经下载过了");
            return nil;
        }
        
        // 创建请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
        
        // 设置请求头
        // Range : bytes=xxx-xxx
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", self.downloadLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        // 创建一个Data任务
        _task = [self.session dataTaskWithRequest:request];
    }
    return _task;
}

/**
 每次重新读取文件的大小

 @return 下载进度
 */
-(NSInteger)downloadLength{
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:_fileFullpath error:nil][NSFileSize] integerValue];
}

-(void)setUrl:(NSURL *)url{
    
    _url = url;
    //设置文件名
    _filename = url.absoluteString.md5String;
    //设置文件的存放路径（caches）
    _fileFullpath = [kCachePath stringByAppendingPathComponent:_filename];
}


- (void)setState:(HWDownLoadState)state {
    // 数据过滤
    if(_state == state) {
        return;
    }
    _state = state;
    
    // 代理, block, 通知
    if (self.stateChangeBlock) {
        self.stateChangeBlock(_state);
    }

    if (_state == HWDownLoadStatePauseSuccess && self.successBlock) {
        
        self.successBlock(self.fileFullpath);
        
        [self.session invalidateAndCancel];
        self.session = nil;
    }
    
}

- (void)setProgress:(float)progress {
    _progress = progress;
    if (self.progressBlock) {
        self.progressBlock(_progress);
    }
}

#pragma mark - 接口
-(void)downLoader:(NSURL *)url downLoadInfo:(void (^)(long long))downLoadInfoBlock progress:(void (^)(float))progressBlock stateChange:(void (^)(HWDownLoadState))stateChangeBlock success:(void (^)(NSString *))successBlock failed:(void (^)(NSError *error))failedBlock{
    
    self.url = url;
    
    self.downLoadInfoBlock = downLoadInfoBlock;
    self.progressBlock = progressBlock;
    self.stateChangeBlock = stateChangeBlock;
    self.successBlock = successBlock;
    self.failedBlock = failedBlock;
}

- (void)startDownload {
    
    if (self.url && self.state == HWDownLoadStatePause) {
        self.state = HWDownLoadStateDownLoading;
        [self.task resume];
    }
    if (self.url && self.state == HWDownLoadStatePauseSuccess) {
        NSLog(@"下载已经完成");
    }
}
- (void)pauseDownload {
    
    if (self.state == HWDownLoadStateDownLoading) {
        self.state = HWDownLoadStatePause;
        [self.task suspend];
    }
    if (self.url && self.state == HWDownLoadStatePauseSuccess) {
        NSLog(@"下载已经完成");
    }
}

-(void)cancelDownload{
    if (self.url && self.state == HWDownLoadStatePauseSuccess) {
        NSLog(@"下载已经完成");
    }else{
        self.state = HWDownLoadStatePause;
        [self.session invalidateAndCancel];
        self.session = nil;
    }
    
}

-(void)deleteDownload{
    [self cancelDownload];
    
    //删除文件
    [[NSFileManager defaultManager] removeItemAtPath:self.fileFullpath error:nil];
    //删除文件信息
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:HWDownLoadInfoPath];
    if (infoDict) {
        [infoDict removeObjectForKey:self.filename];
    }
    [infoDict writeToFile:HWDownLoadInfoPath atomically:YES];

}

#pragma mark - <NSURLSessionDataDelegate>
/**
 * 1.接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // 打开流
    [self.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    self.totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + self.downloadLength;
    
    // 传递给外界 : 总大小 & 本地存储的文件路径
    if (self.downLoadInfoBlock != nil) {
        self.downLoadInfoBlock(self.totalLength);
    }
    // 存储总长度
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:HWDownLoadInfoPath];
    if (infoDict == nil) infoDict = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *info = infoDict[self.filename];
    if (info == nil) info = [NSMutableDictionary dictionary];
    info[@"totalLength"] =  @(self.totalLength);
    infoDict[self.filename] = info;
    [infoDict writeToFile:HWDownLoadInfoPath atomically:YES];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 2.接收到服务器返回的数据（这个方法可能会被调用N次）
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // 写入数据
    [self.stream write:data.bytes maxLength:data.length];
    
    // 下载进度
    self.progress = 1.0 * self.downloadLength / self.totalLength;
    
}

/**
 * 3.请求完毕（成功\失败）
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    
    if (error == nil) {
        // 不一定是成功
        // 数据是肯定可以请求完毕
        // 判断, 本地缓存 == 文件总大小 {filename: filesize: md5:xxx}
        // 如果等于 => 验证, 是否文件完整(file md5 )
        
        self.state = HWDownLoadStatePauseSuccess;
        
    }else {
        
        
        //        NSLog(@"有问题--%zd--%@", error.code, error.localizedDescription);
        // 取消,  断网
        // 999 != 999
        if (-999 == error.code) {
            self.state = HWDownLoadStatePause;
        }else {
            self.state = HWDownLoadStatePauseFailed;
            if (self.failedBlock) {
                self.failedBlock(error);
            }
        }
        
    }
    
    // 关闭流
    [self.stream close];
    self.stream = nil;
    
    // 清除任务
    self.task = nil;
}
@end
