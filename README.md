<h1 align="center"> HWDownLoader</h1>轻量级的下载组件，支持多任务下载、断点下载、断电下载，后续版本考虑添加最大同时下载数

## How To Use
* 代码加载
```
#import <HWDownLoaderManager.h>
...
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
...
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
```

## Installation

HWCyclePics is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HWDownLoader'
```

## Author
本人小菜鸟一枚，欢迎各位同仁和大神指教
<br>我的简书是：https://www.jianshu.com/u/cdd48b9d36e0
<br>我的邮箱是：417705652@qq.com

## Licenses

All source code is licensed under the [MIT License](https://raw.github.com/SDWebImage/SDWebImage/master/LICENSE).
