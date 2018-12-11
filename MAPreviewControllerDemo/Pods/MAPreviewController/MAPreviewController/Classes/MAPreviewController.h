//
//  MAPreviewController.h
//  KF5SDKUI2.0
//
//  Created by admin on 2017/11/21.
//  Copyright © 2017年 kf5. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MAPreviewModel, MAPreviewView;


@interface MAPreviewController : UIViewController

- (instancetype)initWithModels:(NSArray<MAPreviewModel *> *)models selectIndex:(NSInteger)selectIndex;
+ (void)presentForViewController:(UIViewController *)vc models:(NSArray <MAPreviewModel *>*)models selectIndex:(NSInteger)selectIndex;
+ (void)setPlaceholderErrorImage:(UIImage *)image;

@end

@interface MAPreviewPhotoCell : UICollectionViewCell

@property (nonatomic, strong) MAPreviewModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy) void (^longTapGestureBlock)(UIImage *image);
@property (nonatomic, strong) MAPreviewView *previewView;
- (void)recoverSubviews;
@end

@interface MAPreviewVideoCell : UICollectionViewCell

@property (nonatomic, strong) MAPreviewModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);

@end

@interface MAPreviewView : UIView<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) MAPreviewModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy) void (^longTapGestureBlock)(UIImage *image);
- (void)recoverSubviews;

@end

@interface MAPreviewModel: NSObject
// UIImage or NSURL
@property (nonatomic,strong) id value;
@property (nonatomic,strong) UIImage *placeholder;
@property (nonatomic, assign) BOOL  isVideo;
- (instancetype)initWithValue:(id)value placeholder:(UIImage *)placeholder;
- (instancetype)initWithValue:(id)value placeholder:(UIImage *)placeholder isVideo:(BOOL)isVideo;

@end

#pragma mark 转场动画
@interface SwipeUpInteractiveTransition : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

- (instancetype)initWithVC:(UIViewController *)vc;
@property (nonatomic, assign) BOOL shouldComplete;

@end



