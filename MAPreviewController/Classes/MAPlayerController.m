//
//  MAPlayerViewController.m
//  MAAutoLayout
//
//  Created by admin on 12/5/18.
//

#import "MAPlayerController.h"
#import "MAAutoLayout.h"
#import "MAPreviewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "SVProgressHUD.h"
#import <Photos/Photos.h>

@interface MAPlayerController ()<NSURLSessionDelegate>

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) UIButton *closeBtn;
@property (nonatomic, strong) NSURL *localURL;

@end

@implementation MAPlayerController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}
//- (BOOL)shouldAutorotate{
//    return NO;
//}
//
//- (void)deviceOrientationDidChange{
//    CGSize size = CGSizeZero;
//    CGFloat angle = 0;
//    if (self.view.bounds.size.width > self.view.bounds.size.height) {
//        size = self.view.frame.size;
//        angle = 0;
//    }else{
//        size =CGSizeMake(self.view.frame.size.height, self.view.frame.size.width);
//        angle = M_PI_2;
//    }
//    [UIView animateWithDuration:0.2f animations:^{
//        self.view.transform = CGAffineTransformMakeRotation(angle);
//        self.view.bounds = CGRectMake(0, 0, size.width, size.height);
//    }];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    MAPlayer *playView = [[MAPlayer alloc] init];
    playView.controlView.largeButton = nil;
    __weak typeof(self) weakSelf = self;
    playView.statusChange = ^(MAPlayerStatus status) {
        if (status == MAPlayerStatusReadyToPlay) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imageView.hidden = YES;
            });
        }
    };
    playView.longTapBlock = ^{
        if (weakSelf.longTapGestureBlock) {
            weakSelf.longTapGestureBlock(weakSelf.model);
        }else{
            [weakSelf saveVideo:weakSelf.model];
        }
    };
    playView.largeTapBlock = ^{
        if (weakSelf.largeTapBlock) {
            weakSelf.largeTapBlock();
        }
    };
    [self.view addSubview:playView];
    self.playView = playView;
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    closeBtn.layer.cornerRadius = 5;
    closeBtn.backgroundColor = [[UIColor alloc] initWithWhite:0.5 alpha:0.5];
    [self.view addSubview:closeBtn];
    self.closeBtn = closeBtn;
    
    [self.playView ma_makeConstraints:^(MAAutoLayout * _Nonnull make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [closeBtn ma_makeConstraints:^(MAAutoLayout * _Nonnull make) {
        make.top.equalTo(self.view.ma_safeAreaLayoutGuideTop).offset(15);
        make.width.ma_equal(50);
        make.left.equalTo(self.view.ma_safeAreaLayoutGuideLeft).offset(30);
    }];
    
    if (self.model != nil || [self.model.value isKindOfClass:[NSURL class]]) {
        [self assetWithModel:self.model];
        [self.playView resetPlay];
    }
}

- (void)assetWithModel:(MAPreviewModel *)model {
    self.model = model;
    if (model == nil || ![model.value isKindOfClass:[NSURL class]]) {
        return;
    }
    if (model.placeholder) {
        self.imageView.hidden = NO;
        self.imageView.image = model.placeholder;
        [self.imageView ma_makeConstraints:^(MAAutoLayout * _Nonnull make) {
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(self.view);
            make.width.equalTo(self.view);
            make.height.equalTo(self.imageView.ma_width).multiplier(self.imageView.image.size.height / self.imageView.image.size.width);
        }];
    }
    
    NSURL *url = model.value;
    if (!url.isFileURL) {
        if (self.localURL) {
            url = self.localURL;
        }else{
            NSString *localPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[MAPlayerController md5HexDigest:url.absoluteString]]];
            if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
                url = [NSURL fileURLWithPath:localPath];
                self.localURL = url;
            }
        }
    }
    [self.playView assetWithURL:url];
    self.playView.mode = MALayerVideoGravityResizeAspect;
}

- (void)closeAction:(UIButton *)btn {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dealloc{
    [self.playView stop];
    self.playView = nil;
}


#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    [SVProgressHUD showProgress:1.0 * totalBytesWritten / totalBytesExpectedToWrite];
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    NSURL *localURL= [[[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[MAPlayerController md5HexDigest:downloadTask.originalRequest.URL.absoluteString]]];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:localURL error:nil];
    [self saveVideoWithUrl:localURL location:nil completion:^(PHAsset *asset, NSError *error) {
        if (error) {
            [SVProgressHUD showSuccessWithStatus:@"保存失败"];
        }else{
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        }
    }];
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"下载失败"];
    }
}

#pragma mark - other

- (void)saveVideo:(MAPreviewModel *)model{
    // 如果localURL存在,说明已经下载过了,直接使用这个url即可
    NSURL *url = self.localURL ?: model.value;
    if (url == nil)  return;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否保存视频到本地" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self)weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (url.isFileURL) {
            [weakSelf saveVideoWithUrl:url location:nil completion:^(PHAsset *asset, NSError *error) {
                [SVProgressHUD showSuccessWithStatus:@"保存成功"];
            }];
        }else{
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:weakSelf delegateQueue:[NSOperationQueue mainQueue]];
            [[session downloadTaskWithURL:url] resume];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveVideoWithUrl:(NSURL *)url location:(CLLocation *)location completion:(void (^)(PHAsset *asset, NSError *error))completion {
    __block NSString *localIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
        localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
        if (location) {
            request.location = location;
        }
        request.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && completion) {
                PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil] firstObject];
                completion(asset, nil);
            } else if (error) {
                NSLog(@"保存视频出错:%@",error.localizedDescription);
                if (completion) {
                    completion(nil, error);
                }
            }
        });
    }];
}

+ (NSString *)md5HexDigest:(NSString *)input{
    if (input == nil) return nil;
    
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (int)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for(int i = 0; i< CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X",result[i]];
    }
    return ret;
}

@end
