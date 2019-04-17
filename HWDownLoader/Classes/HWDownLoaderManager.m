//
//  HWDownLoaderManager.m
//  HWDownLoader_Example
//
//  Created by 袁海文 on 2019/4/16.
//  Copyright © 2019年 wozaizhelishua. All rights reserved.
//

#import "HWDownLoaderManager.h"
#import "NSString+Hash.h"

@interface HWDownLoaderManager()<NSCopying, NSMutableCopying>

/**
 保存下载器，key: md5(url)  value: HWDownLoader
 */
@property (nonatomic, strong) NSMutableDictionary *downLoadInfo;

@end

@implementation HWDownLoaderManager
static HWDownLoaderManager *_shareInstance;
#pragma mark - 私有方法
+ (instancetype)shareInstance {
    if (_shareInstance == nil) {
        _shareInstance = [[self alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _shareInstance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _shareInstance;
}

- (NSMutableDictionary *)downLoadInfo {
    if (!_downLoadInfo) {
        _downLoadInfo = [NSMutableDictionary dictionary];
    }
    return _downLoadInfo;
}
#pragma mark - 接口
-(void)downLoader:(NSURL *)url downLoadInfo:(void (^)(long long))downLoadInfoBlock progress:(void (^)(float))progressBlock stateChange:(void (^)(HWDownLoadState))stateChangeBlock success:(void (^)(NSString *))successBlock failed:(void (^)(NSError *))failedBlock{
    
    // 1. url
    NSString *urlMD5 = [url.absoluteString md5String];
    
    // 2. 根据 urlMD5 , 查找相应的下载器
    HWDownLoader *downLoader = self.downLoadInfo[urlMD5];
    if (downLoader == nil) {
        downLoader = [[HWDownLoader alloc] init];
        self.downLoadInfo[urlMD5] = downLoader;
    }
    
    [downLoader downLoader:url downLoadInfo:downLoadInfoBlock progress:progressBlock stateChange:stateChangeBlock success:successBlock failed:failedBlock];
    
//    [downLoader downLoader:url downLoadInfo:downLoadInfoBlock progress:progressBlock stateChange:stateChangeBlock success:^(NSString *filePath) {
//
//        successBlock(filePath);
//
//
//
//    } failed:^(NSError *error) {
//        failedBlock(error);
//    }];
}

- (void)startWithURL:(NSURL *)url {
    
    NSString *urlMD5 = [url.absoluteString md5String];
    HWDownLoader *downLoader = self.downLoadInfo[urlMD5];
    if (downLoader == nil) {
        NSLog(@"下载器为空，已经完成下载或者尚未开始下载");
        return;
    }
    [downLoader startDownload];
}

- (void)pauseWithURL:(NSURL *)url {
    
    NSString *urlMD5 = [url.absoluteString md5String];
    HWDownLoader *downLoader = self.downLoadInfo[urlMD5];
    if (downLoader == nil) {
        NSLog(@"下载器为空，已经完成下载或者尚未开始下载");
        return;
    }
    [downLoader pauseDownload];
}

- (void)cancelWithURL:(NSURL *)url {
    
    NSString *urlMD5 = [url.absoluteString md5String];
    HWDownLoader *downLoader = self.downLoadInfo[urlMD5];
    if (downLoader == nil) {
        NSLog(@"下载器为空，已经完成下载或者尚未开始下载");
        return;
    }
    [downLoader cancelDownload];
}

- (void)deleteWithURL:(NSURL *)url {
    
    NSString *urlMD5 = [url.absoluteString md5String];
    HWDownLoader *downLoader = self.downLoadInfo[urlMD5];
    if (downLoader == nil) {
        NSLog(@"下载器为空，已经完成下载或者尚未开始下载");
        return;
    }
    [downLoader deleteDownload];
    
    // 删除文件后再移除下载器
    [self.downLoadInfo removeObjectForKey:urlMD5];
}


- (void)startAll {
    
    [self.downLoadInfo.allValues performSelector:@selector(startDownload) withObject:nil];
}

- (void)pauseAll {
    
    [self.downLoadInfo.allValues performSelector:@selector(pauseDownload) withObject:nil];
    
}

- (void)cancelAll {
    
    [self.downLoadInfo.allValues performSelector:@selector(cancelDownload) withObject:nil];
    
}

- (void)deleteAll {
    
    [self.downLoadInfo.allValues performSelector:@selector(deleteDownload) withObject:nil];
    
    [self.downLoadInfo removeAllObjects];
}
@end
