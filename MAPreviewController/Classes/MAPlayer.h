//
//  MAView.h
//  MAPlayer
//
//  Created by fengyunjue on 2017/4/10.
//  Copyright © 2017年 fengyunjue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//横竖屏的时候过渡动画时间，设置为0.0则是无动画
#define kTransitionTime 0.2
//填充模式枚举值
typedef NS_ENUM(NSInteger,MALayerVideoGravity){
    MALayerVideoGravityResizeAspect,
    MALayerVideoGravityResizeAspectFill,
    MALayerVideoGravityResize,
};
//播放状态枚举值
typedef NS_ENUM(NSInteger,MAPlayerStatus){
    MAPlayerStatusFailed,
    MAPlayerStatusReadyToPlay,
    MAPlayerStatusUnknown,
    MAPlayerStatusBuffering,
    MAPlayerStatusPlaying,
    MAPlayerStatusStopped,
};
@class MAControlView;
@class MAPauseOrPlayView;

@interface MAPlayer : UIView{
    id playbackTimerObserver;
}

@property (nonatomic,strong,readonly) AVPlayerLayer *playerLayer;
//当前播放url
@property (nonatomic,strong) NSURL *url;
//底部控制视图
@property (nonatomic,strong) MAControlView *controlView;
//暂停和播放视图
@property (nonatomic,strong) MAPauseOrPlayView *pauseOrPlayView;
//添加标题
@property (nonatomic,strong) UILabel *titleLabel;
//加载动画
@property (nonatomic,strong) UIActivityIndicatorView *activityIndeView;
// 背景
@property (nonatomic, strong) UIImageView *backgroundView;

//AVPlayer
@property (nonatomic,strong) AVPlayer *player;
//AVPlayer的播放item
@property (nonatomic,strong) AVPlayerItem *item;
//总时长
@property (nonatomic,assign) CMTime totalTime;
//当前时间
@property (nonatomic,assign) CMTime currentTime;
//资产AVURLAsset
@property (nonatomic,strong) AVURLAsset *anAsset;
//播放器Playback Rate
@property (nonatomic,assign) CGFloat rate;
//播放状态
@property (nonatomic,assign,readonly) MAPlayerStatus status;
//videoGravity设置屏幕填充模式，（只写）
@property (nonatomic,assign) MALayerVideoGravity mode;
//是否正在播放
@property (nonatomic,assign,readonly) BOOL isPlaying;
//设置标题
@property (nonatomic,copy) NSString *title;
//长按事件
@property (nonatomic, copy) void (^longTapBlock)(void);
//全屏事件
@property (nonatomic, copy) void (^largeTapBlock)(void);
//   状态变化
@property (nonatomic, copy) void (^statusChange)(MAPlayerStatus status);

//与url初始化
-(instancetype)initWithUrl:(NSURL *)url;
//将播放url放入资产中初始化播放器
-(void)assetWithURL:(NSURL *)url;
//公用同一个资产请使用此方法初始化
-(instancetype)initWithAsset:(AVURLAsset *)asset;
//播放
-(void)play;
//暂停
-(void)pause;
//停止 （移除当前视频播放下一个或者销毁视频，需调用Stop方法）
-(void)stop;
- (void)resetPlay;

@end


#pragma mark Other

@interface SZSlider : UISlider
@end

@interface MAPauseOrPlayView : UIView
@property (nonatomic, copy) void(^clickBlock)(BOOL isPlay);
@property (nonatomic,assign) BOOL isPlay;
@property (nonatomic,weak) UIButton *imageBtn;
@end


@class MAControlView;
@protocol MAControlViewDelegate <NSObject>
@required
/**
 点击UISlider获取点击点
 
 @param controlView 控制视图
 @param value 当前点击点
 */
-(void)controlView:(MAControlView *)controlView pointSliderLocationWithCurrentValue:(CGFloat)value;

/**
 拖拽UISlider的knob的时间响应代理方法
 
 @param controlView 控制视图
 @param slider UISlider
 */
-(void)controlView:(MAControlView *)controlView draggedPositionWithSlider:(UISlider *)slider ;

/**
 点击放大按钮的响应事件
 
 @param controlView 控制视图
 @param button 全屏按钮
 */
-(void)controlView:(MAControlView *)controlView withLargeButton:(UIButton *)button;
@end


@interface MAControlView : UIView
//全屏按钮
@property (nonatomic,strong) UIButton *largeButton;
//进度条当前值
@property (nonatomic,assign) CGFloat value;
//最小值
@property (nonatomic,assign) CGFloat minValue;
//最大值
@property (nonatomic,assign) CGFloat maxValue;
//当前时间
@property (nonatomic,copy) NSString *currentTime;
//总时间
@property (nonatomic,copy) NSString *totalTime;
//缓存条当前值
@property (nonatomic,assign) CGFloat bufferValue;
//UISlider手势
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
//代理方法
@property (nonatomic,weak) id<MAControlViewDelegate> delegate;

@end
