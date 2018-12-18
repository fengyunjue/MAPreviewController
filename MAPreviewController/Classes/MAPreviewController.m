//
//  MAPreviewController.m
//  5SDKUI2.0
//
//  Created by admin on 2017/11/21.
//  Copyright © 2017年 kf5. All rights reserved.
//

#import "MAPreviewController.h"
#import "UIImageView+WebCache.h"
#import "MAAutoLayout.h"
#import "SVProgressHUD.h"
#import "MAPlayer.h"
#import <CommonCrypto/CommonDigest.h>
#import "MAPlayerController.h"

static UIImage *placeHolderErrorImage;
static NSString *cellID = @"MAPreviewPhotoCell";
static NSString *cellVideoID = @"MAPreviewVideoCell";

@interface MAPreviewVideoCell()
@property (nonatomic, weak) MAPlayer *playView;
@end

@interface MAPreviewModel()

@property (nonatomic, strong) NSURL *localURL;

@end

static kLargeType LargeType = kLargeTypeHidden;

@interface MACollectionView : UICollectionView
@end

@implementation MACollectionView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    /*
     直接拖动UISlider，此时touch时间在150ms以内，UIScrollView会认为是拖动自己，从而拦截了event，导致UISlider接受不到滑动的event。但是只要按住UISlider一会再拖动，此时此时touch时间超过150ms，因此滑动的event会发送到UISlider上。
     */
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isKindOfClass:NSClassFromString(@"UISlider")]) {
        //如果响应view是UISlider,则scrollview禁止滑动
        self.scrollEnabled = NO;
    }else{
        //如果不是,则恢复滑动
        self.scrollEnabled = YES;
    }
    return view;
}

@end

@interface MAPreviewController()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) NSArray <MAPreviewModel *>*models;
@property (nonatomic,weak) MACollectionView *collectionView;

@property (nonatomic,weak) UILabel *numberLabel;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, assign) NSInteger displayIndex;

@property (nonatomic, strong) SwipeUpInteractiveTransition *transitionController;

@end

@implementation MAPreviewController
+ (void)setLargeType:(kLargeType)largeType{
    LargeType = largeType;
}
- (instancetype)initWithModels:(NSArray<MAPreviewModel *> *)models selectIndex:(NSInteger)selectIndex{
    self = [super init];
    if (self) {
        _models = models;
        _selectIndex = selectIndex;
        _transitionController = [[SwipeUpInteractiveTransition alloc] initWithVC:self];
    }
    return self;
}

+ (void)presentForViewController:(UIViewController *)vc models:(NSArray<MAPreviewModel *> *)models selectIndex:(NSInteger)selectIndex{
    MAPreviewController *previewController = [[MAPreviewController alloc] initWithModels:models selectIndex:selectIndex];
    [vc presentViewController:previewController animated:YES completion:nil];
}

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

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if (!placeHolderErrorImage) placeHolderErrorImage = [MAPreviewController imageNamed:@"placeholder_image"];
    
    if (self.models.count == 0) return;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    MACollectionView *collectionView = [[MACollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.automaticallyAdjustsScrollViewInsets = NO;
    collectionView.backgroundColor = [UIColor blackColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = YES;
    collectionView.scrollsToTop = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.contentOffset = CGPointZero;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    UILabel *numberLabel = [[UILabel alloc] init];
    numberLabel.font = [UIFont boldSystemFontOfSize:20];
    numberLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:numberLabel];
    self.numberLabel = numberLabel;
    
    [numberLabel ma_makeConstraints:^(MAAutoLayout * _Nonnull make) {
        make.top.equalTo(self.view.ma_safeAreaLayoutGuideTop).offset(15);
        make.centerX.equalTo(self.view);
    }];
    [collectionView ma_makeConstraints:^(MAAutoLayout *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view).offset(-10);
        make.right.equalTo(self.view).offset(10);
        make.bottom.equalTo(self.view);
    }];
    
    [_collectionView registerClass:[MAPreviewPhotoCell class] forCellWithReuseIdentifier:cellID];
    [_collectionView registerClass:[MAPreviewVideoCell class] forCellWithReuseIdentifier:cellVideoID];
    
    if (self.selectIndex < self.models.count) self.currentIndex = self.selectIndex;
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld/%lu", currentIndex+1,(unsigned long)self.models.count];
}
- (CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height);
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _collectionView.contentSize = CGSizeMake(self.models.count * (self.collectionView.frame.size.width + 20), self.collectionView.frame.size.height);
    [_collectionView setContentOffset:CGPointMake(self.collectionView.bounds.size.width * self.currentIndex, 0)];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat offSetWidth = scrollView.contentOffset.x;
    
    offSetWidth = offSetWidth +  ((self.view.frame.size.width + 20) * 0.5);
    NSInteger currentIndex = offSetWidth / (self.view.frame.size.width + 20);
    if (currentIndex < _models.count && self.currentIndex != currentIndex) {
        self.currentIndex = currentIndex;
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MAPreviewModel *model = self.models[indexPath.row];
    __weak typeof(self)weakSelf = self;
    if (model.isVideo) {
        MAPreviewVideoCell *previewVideoCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellVideoID forIndexPath:indexPath];
        previewVideoCell.model = model;
        [previewVideoCell setSingleTapGestureBlock:^{
            [weakSelf dismissView];
        }];
        return previewVideoCell;
    }else {
        MAPreviewPhotoCell *previewPhotoCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        previewPhotoCell.model = model;
        [previewPhotoCell setLongTapGestureBlock:^(UIImage *image) {
            [weakSelf showSaveActivityView:image];
        }];
        [previewPhotoCell setSingleTapGestureBlock:^{
            [weakSelf dismissView];
        }];
        return previewPhotoCell;
    }
}

- (void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showSaveActivityView:(UIImage *)image{
    UIActivityViewController *activityViewController =  [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {
        activityViewController.popoverPresentationController.sourceView = self.view;
    }
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[MAPreviewPhotoCell class]]) {
        [(MAPreviewPhotoCell *)cell recoverSubviews];
    }else if ([cell isKindOfClass:[MAPreviewVideoCell class]]) {
        [((MAPreviewVideoCell *)cell).playView resetPlay];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *oldCell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
   if ([oldCell isKindOfClass:[MAPreviewVideoCell class]]) {
        [((MAPreviewVideoCell *)oldCell).playView resetPlay];
    }
    
    if ([cell isKindOfClass:[MAPreviewPhotoCell class]]){
        [(MAPreviewPhotoCell *)cell recoverSubviews];
    }else if ([cell isKindOfClass:[MAPreviewVideoCell class]]) {
        [((MAPreviewVideoCell *)cell).playView pause];
    }
}
+ (void)setPlaceholderErrorImage:(UIImage *)image{
    placeHolderErrorImage = image;
}

+ (UIImage *)imageNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:[@"MAPreviewController.bundle" stringByAppendingPathComponent:name]];
    if (!image) {
        image = [UIImage imageNamed:[@"Frameworks/MAPreviewController.framework/MAPreviewController.bundle" stringByAppendingPathComponent:name]];
    }
    if (!image) {
        image = [UIImage imageNamed:name];
    }
    return image;
}

@end

@interface MAPreviewVideoCell()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIButton *closeBtn;
@property (nonatomic, strong) MAPlayerController *playerController;

@end

@implementation MAPreviewVideoCell

- (MAPlayer *)playView{
    return self.playerController.playView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        MAPlayerController *playerController = [[MAPlayerController alloc] init];
        playerController.largeType = LargeType;
        [self.contentView addSubview:playerController.view];
        
        __weak typeof(self) weakSelf = self;
        playerController.singleTapGestureBlock = ^{
            if (weakSelf.singleTapGestureBlock) {
                weakSelf.singleTapGestureBlock();
            }
        };
        self.playerController = playerController;
        [playerController.view ma_makeConstraints:^(MAAutoLayout * _Nonnull make) {
            make.left.equalTo(self.contentView).offset(10);
            make.right.equalTo(self.contentView).offset(-10);
            make.top.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setModel:(MAPreviewModel *)model{
    _model = model;
    if ([model.value isKindOfClass:[NSURL class]]) {
        [self.playerController assetWithModel:model];
    }else{
        NSAssert(NO, @"model的格式错误");
    }
}

- (void)closeAction:(UIButton *)btn {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

- (void)dealloc{
    [self.playView stop];
    self.playView = nil;
}

@end

@implementation MAPreviewPhotoCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.previewView = [[MAPreviewView alloc] initWithFrame:CGRectZero];
        __weak typeof(self) weakSelf = self;
        [self.previewView setSingleTapGestureBlock:^{
            if (weakSelf.singleTapGestureBlock) {
                weakSelf.singleTapGestureBlock();
            }
        }];
        [self.previewView setLongTapGestureBlock:^(UIImage *image) {
            if (weakSelf.longTapGestureBlock) {
                weakSelf.longTapGestureBlock(image);
            }
        }];
        [self.contentView addSubview:self.previewView];
    }
    return self;
}

- (void)setModel:(MAPreviewModel *)model{
    _model = model;
    _previewView.model = model;
}

- (void)recoverSubviews {
    [_previewView recoverSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.previewView.frame = self.bounds;
}

@end



@implementation MAPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        [self addSubview:_scrollView];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [_scrollView addSubview:_imageView];
    
        [self configGestureRecognizer];
    }
    return self;
}

- (void)configGestureRecognizer {
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.numberOfTapsRequired = 2;
    [tap1 requireGestureRecognizerToFail:tap2];
    [self addGestureRecognizer:tap2];
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    [self addGestureRecognizer:longTap];
}

- (void)setModel:(MAPreviewModel *)model{
    _model = model;
    if ([model.value isKindOfClass:[UIImage class]]) {
        self.imageView.image = model.value;
        [self resizeSubviews];
        [SVProgressHUD dismiss];
    }else if ([model.value isKindOfClass:[NSURL class]]){
        __weak typeof(self)weakSelf = self;
        [self.imageView sd_setImageWithURL:model.value placeholderImage:model.placeholder options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat progress = receivedSize / (CGFloat)expectedSize;
                progress = progress > 0.02 ? progress : 0.02;
                [SVProgressHUD showProgress:progress];
            });
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    weakSelf.imageView.image = placeHolderErrorImage;
                }else{
                    weakSelf.imageView.image = image;
                }
                [weakSelf resizeSubviews];
                [SVProgressHUD dismiss];
            });
        }];
    }else{
        NSAssert(NO, @"model的格式错误");
    }
}

- (void)recoverSubviews {
    [_scrollView setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews{
    CGSize imageSize = self.imageView.image.size;
    
    if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
        imageSize = CGSizeMake(320, 320);
    }
    CGRect imageFrame = CGRectZero;
    CGFloat scale = MIN(self.scrollView.frame.size.height / imageSize.height, self.scrollView.frame.size.width / imageSize.width);
    imageFrame.size.width = floor(scale * imageSize.width);
    imageFrame.size.height = floor(scale * imageSize.height);
    _imageView.frame = imageFrame;
    _imageView.center = CGPointMake(self.scrollView.frame.size.width/2, self.scrollView.frame.size.height/2);
    
    _scrollView.contentSize = imageFrame.size;
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = _imageView.frame.size.height <= self.frame.size.height ? NO : YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = CGRectMake(10, 0, self.frame.size.width - 20, self.frame.size.height);
    [self recoverSubviews];
}

#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        _scrollView.contentInset = UIEdgeInsetsZero;
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

- (void)longTap:(UILongPressGestureRecognizer *)tap{
    if (tap.state == UIGestureRecognizerStateBegan && self.longTapGestureBlock && self.imageView.image != placeHolderErrorImage) {
        self.longTapGestureBlock(self.imageView.image);
    }
}
#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

#pragma mark - Private

- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (_scrollView.frame.size.width > _scrollView.contentSize.width) ? ((_scrollView.frame.size.width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.frame.size.height > _scrollView.contentSize.height) ? ((_scrollView.frame.size.height - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.imageView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}

@end

@implementation MAPreviewModel

- (instancetype)initWithValue:(id)value placeholder:(UIImage *)placeholder{
    return [self initWithValue:value placeholder:placeholder isVideo:NO];
}

- (instancetype)initWithValue:(id)value placeholder:(UIImage *)placeholder isVideo:(BOOL)isVideo {
    self = [super init];
    if (self) {
        _value = value;
        _placeholder = placeholder;
        _isVideo = isVideo;
    }
    return self;
}

@end

#pragma mark 转场动画
@interface SwipeUpInteractiveTransition ()

@property (nonatomic, assign) BOOL interacting;
@property (nonatomic, weak) UIViewController *presentingVC;

@end

@implementation SwipeUpInteractiveTransition
- (instancetype)initWithVC:(UIViewController *)vc{
    self = [super init];
    if (self) {
        _presentingVC = vc;
        vc.transitioningDelegate = self;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [vc.view addGestureRecognizer:pan];
    }
    return self;
}

-(CGFloat)completionSpeed{
    return 1 - self.percentComplete;
}
- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer {

    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            // 1. Mark the interacting flag. Used when supplying it in delegate.
            self.interacting = YES;
            [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged: {
            // 2. Calculate the percentage of guesture
            CGFloat fraction = translation.y / ([UIScreen mainScreen].bounds.size.height * 0.6);
            //Limit it between 0 and 1
            fraction = fminf(fmaxf(fraction, 0.0), 1.0);
            self.shouldComplete = (fraction > 0.25);

            [self updateInteractiveTransition:fraction];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            // 3. Gesture over. Check if the transition should happen or not
            self.interacting = NO;
            if (!self.shouldComplete || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                [self cancelInteractiveTransition];
            } else {
                [self finishInteractiveTransition];
            }
            break;
        }
        default:
            break;
    }
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    // 1. Get controllers from transition context
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    // 2. Set init frame for fromVC
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect initFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect finalFrame = CGRectOffset(initFrame, 0, screenBounds.size.height);

    // 3. Add target view to the container, and move it to back.
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toVC.view];
    [containerView sendSubviewToBack:toVC.view];

    // 4. Do animate now
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        fromVC.view.frame = finalFrame;
        toVC.view.frame = initFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return self;
}

-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interacting ? self : nil;
}

@end
