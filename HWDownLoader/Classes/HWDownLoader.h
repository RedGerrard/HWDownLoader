//
//  HWDownLoader.h
//  HWDownLoader_Example
//
//  Created by 袁海文 on 2019/4/12.
//  Copyright © 2019年 wozaizhelishua. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HWDownLoadState) {
    HWDownLoadStatePause,
    HWDownLoadStateDownLoading,
    HWDownLoadStatePauseSuccess,
    HWDownLoadStatePauseFailed
};

@interface HWDownLoader : NSObject

/**下载状态*/
@property (nonatomic, assign, readonly) HWDownLoadState state;
/**下载进度*/
@property (nonatomic, assign, readonly) float progress;

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
 */
- (void)startDownload;

/**
 暂停下载
 */
- (void)pauseDownload;

/**
 取消下载
 */
- (void)cancelDownload;

/**
 删除下载
 */
-(void)deleteDownload;

@end
