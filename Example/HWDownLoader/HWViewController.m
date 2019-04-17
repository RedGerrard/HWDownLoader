//
//  HWViewController.m
//  HWDownLoader
//
//  Created by wozaizhelishua on 04/12/2019.
//  Copyright (c) 2019 wozaizhelishua. All rights reserved.
//

#import "HWViewController.h"
#import "HWDownLoaderManager.h"

@interface HWViewController ()

@property (nonatomic, strong) NSURL *url;
@end

@implementation HWViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	NSLog(@"%@",NSTemporaryDirectory());
  
    self.url = [NSURL URLWithString:@"http://localhost:8080/MJServer/resources/videos/minion_01.mp4"];
 
    [[HWDownLoaderManager shareInstance]downLoader:self.url downLoadInfo:^(long long totalSize) {
        NSLog(@"minion_01.mp4 = %lld",totalSize);
    } progress:^(float progress) {
        NSLog(@"%f", progress);
    } stateChange:^(HWDownLoadState state) {
        NSLog(@"%lu",(unsigned long)state);
    } success:^(NSString *filePath) {
        NSLog(@"%@",filePath);
    } failed:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (IBAction)download:(id)sender {
  
    [[HWDownLoaderManager shareInstance]startWithURL:self.url];
}

- (IBAction)pause:(id)sender {
 
    [[HWDownLoaderManager shareInstance]pauseWithURL:self.url];
}

- (IBAction)cancel:(id)sender {
    
    [[HWDownLoaderManager shareInstance]cancelWithURL:self.url];
}

- (IBAction)delete:(id)sender {
 
    [[HWDownLoaderManager shareInstance]deleteWithURL:self.url];
}
@end
