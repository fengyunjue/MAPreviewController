//
//  ViewController.m
//  MAPreviewControllerDemo
//
//  Created by admin on 12/4/18.
//  Copyright © 2018 fengyunjue. All rights reserved.
//

#import "ViewController.h"
#import "MAPreviewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MAAutoLayout.h"
#import "MAPlayerController.h"

@interface ViewController ()
@property (nonatomic, strong) NSURL *url;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, weak) UIView *bgView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.url = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"123.mp4" ofType:nil]];
    
//    UIView *view = [[UIView alloc] init];
//    view.backgroundColor = [UIColor redColor];
//    view.layer.borderWidth = 2;
//    [self.view addSubview:view];
//    self.bgView = view;
//
//    UILabel *label = [[UILabel alloc] init];
//    label.text = @"无量天尊";
//    [view addSubview:label];
//
//    [view ma_makeConstraints:^(MAAutoLayout * _Nonnull make) {
//        make.top.equalTo(self.view).offset(10);
//        make.left.equalTo(self.view).offset(10);
//        make.right.equalTo(self.view).offset(-10);
//        make.bottom.equalTo(self.view).offset(-10);
////        make.width.equalTo(self.view).offset(-20);
////        make.height.equalTo(self.view).offset(-20);
////        make.centerY.equalTo(self.view);
////        make.centerX.equalTo(self.view);
//    }];
//
//    [label ma_makeConstraints:^(MAAutoLayout * _Nonnull make) {
//        make.centerX.equalTo(view);
//        make.centerY.equalTo(view);
//    }];
//
    

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    self.bgView.transform = CGAffineTransformMakeRotation(M_PI_2);
//    [self.bgView ma_makeConstraints:^(MAAutoLayout * _Nonnull make) {
//        make.top.equalTo(self.view.ma_left).offset(10);
//        make.left.equalTo(self.view.ma_right).offset(10);
//        make.right.equalTo(self.view.ma_bottom).offset(-10);
//        make.bottom.equalTo(self.view.ma_right).offset(-10);
//    }];

    MAPlayerController *vc = [[MAPlayerController alloc]init];
    vc.largeType = kLargeTypeView;
    vc.model = [[MAPreviewModel alloc] initWithValue:[NSURL URLWithString:@"https://kchat-files-oss.kf5.com/5bfe5062c41a73374c150c8093e8a5b1caff9432090198098.mp4"] placeholder:self.imageView.image isVideo:YES];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)openVideo:(UIButton *)sender {
    NSMutableArray *array = [NSMutableArray array];
    UIImage *image = [UIImage imageNamed:@"keyboard"];
    
    [array addObject:[[MAPreviewModel alloc] initWithValue:self.url placeholder:self.imageView.image isVideo:YES]];
    [array addObject: [[MAPreviewModel alloc] initWithValue:[NSURL URLWithString:@"https://kchat-files-oss.kf5.com/5bfe5062c41a73374c150c8093e8a5b1caff9432090198098.mp4"] placeholder:image isVideo:YES]];
    
    [array addObject: [[MAPreviewModel alloc] initWithValue:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543919037737&di=f374f026aae9461fd650c8d6ad239759&imgtype=0&src=http%3A%2F%2Fimg.nga.178.com%2Fattachments%2Fmon_201708%2F25%2F-7Q13t-4wn4K1aT1kSdw-dw.jpg"] placeholder:nil isVideo:NO]];
    [array addObject:[[MAPreviewModel alloc] initWithValue:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543919082451&di=783aea7f795f53b4f88aa4d0b72e4478&imgtype=0&src=http%3A%2F%2Fpic.58pic.com%2F58pic%2F11%2F85%2F48%2F00F58PICkuA.jpg"] placeholder:image isVideo:NO]];
    [array addObject:[[MAPreviewModel alloc] initWithValue:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1543919096777&di=a412c864e14f523852ad6ac95d19b7c7&imgtype=jpg&src=http%3A%2F%2Fimg3.imgtn.bdimg.com%2Fit%2Fu%3D944811728%2C74297326%26fm%3D214%26gp%3D0.jpg"] placeholder:image isVideo:NO]];
    
    
    MAPreviewController *vc = [[MAPreviewController alloc]initWithModels:array selectIndex:0];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)setUrl:(NSURL *)url{
    _url = url;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:self.url options:opts];
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
        generator.appliesPreferredTrackTransform = YES;
        generator.maximumSize = CGSizeMake(200, 200);
        NSError *error = nil;
        CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(0, 10) actualTime:NULL error:&error];
        if (error == nil){
            UIImage *image = [UIImage imageWithCGImage:img];
            CGImageRelease(img);
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imageView.image = image;
            });
        }
    });
}

@end
