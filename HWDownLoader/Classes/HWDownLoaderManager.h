//
//  HWDownLoaderManager.h
//  HWDownLoader_Example
//
//  Created by 袁海文 on 2019/4/16.
//  Copyright © 2019年 wozaizhelishua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWDownLoader.h"

@interface HWDownLoaderManager : NSObject

+ (instancetype)shareInstance;

/**
 下载设置
 
 @param url 下载网址
 @param downLoadInfoBlock 获取下载文件大小的回调
 @param progressBlock 获取下载进度的回调
 @param stateChangeBlock 下载状态更新的回调
 @param successBlock 下载成功的回调
 @param failedBlock 下载失败的回调
 */
- (void)downLoader:(NSURL *)url downLoadInfo:(void(^)(long long totalSize))downLoadInfoBlock progress:(void(^)(float progress))progressBlock stateChange:(void(^)(HWDownLoadState state))stateChangeBlock success:(void(^)(NSString *filePath))successBlock failed:(void(^)(NSError *error))failedBlock;

/**
 开启下载

 @param url 下载网址
 */
- (void)startWithURL:(NSURL *)url;

/**
 暂停下载
 
 @param url 下载网址
 */
- (void)pauseWithURL:(NSURL *)url;

/**
 取消下载
 
 @param url 下载网址
 */
- (void)cancelWithURL:(NSURL *)url;

/**
 删除下载
 
 @param url 下载网址
 */
- (void)deleteWithURL:(NSURL *)url;

/**
 开启全部
 */
- (void)startAll;

/**
 暂停全部
 */
- (void)pauseAll;

/**
 取消全部
 */
- (void)cancelAll;

/**
 删除全部
 */
- (void)deleteAll;
@end
