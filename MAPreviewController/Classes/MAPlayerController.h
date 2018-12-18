//
//  MAPlayerViewController.h
//  MAAutoLayout
//
//  Created by admin on 12/5/18.
//

#import <UIKit/UIKit.h>
#import "MAPlayerView.h"

typedef NS_ENUM(NSInteger,kLargeType) {
    kLargeTypeHidden = 0,// 隐藏全屏按钮
    kLargeTypeView,         // view旋转
    kLargeTypeSystem     // app支持旋转
};

@class MAPreviewModel;

@interface MAPlayerController : UIViewController

@property (nonatomic, strong) MAPreviewModel *model;
@property (nonatomic, weak) MAPlayerView *playView;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy) void (^longTapGestureBlock)(MAPreviewModel *model);

// 全屏按钮状态
@property (nonatomic, assign) kLargeType  largeType;

- (void)assetWithModel:(MAPreviewModel *)model;

@end
