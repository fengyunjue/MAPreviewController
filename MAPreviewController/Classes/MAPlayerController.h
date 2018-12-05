//
//  MAPlayerViewController.h
//  MAAutoLayout
//
//  Created by admin on 12/5/18.
//

#import <UIKit/UIKit.h>
#import "MAPlayer.h"

@class MAPreviewModel;

@interface MAPlayerController : UIViewController

@property (nonatomic, strong) MAPreviewModel *model;
@property (nonatomic, weak) MAPlayer *playView;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy) void (^longTapGestureBlock)(MAPreviewModel *model);
// 全屏按钮
@property (nonatomic, copy) void (^largeTapBlock)(void);

- (void)assetWithModel:(MAPreviewModel *)model;

@end
