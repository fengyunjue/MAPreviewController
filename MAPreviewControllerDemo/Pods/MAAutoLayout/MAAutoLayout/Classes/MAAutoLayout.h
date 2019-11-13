//
//  MAAutoLayout.h
//  MAAutoLayout
//
//  Created by admin on 2017/11/28.
//

#import <UIKit/UIKit.h>

#pragma mark - view属性
@interface MAViewAttribute: NSObject

@property (nonatomic, weak, readonly) id _Nullable item;
@property (nonatomic, assign, readonly) NSLayoutAttribute layoutAttribute;
- (id _Nonnull )initWithItem:(id _Nullable )item layoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end

#pragma mark - autolayout操作
@interface MAAutoLayoutMaker : NSObject

@property (nullable, nonatomic,strong, readonly) NSLayoutConstraint *layoutConstraint;

- (nonnull instancetype)initWithFirstItem:(nonnull id)firstItem firstAttribute:(NSLayoutAttribute)firstAttribute;
// 偏移量
- (MAAutoLayoutMaker * _Nonnull (^_Nonnull)(CGFloat offset))offset;
// 关系
- (MAAutoLayoutMaker * _Nonnull (^_Nonnull)(id _Nonnull attr))equalTo;
- (MAAutoLayoutMaker * _Nonnull (^_Nonnull)(id _Nonnull attr))greaterThanOrEqualTo;
- (MAAutoLayoutMaker * _Nonnull (^_Nonnull)(id _Nonnull attr))lessThanOrEqualTo;
// 赋值
- (MAAutoLayoutMaker * _Nonnull (^_Nonnull)(CGFloat constant))ma_equal;
- (MAAutoLayoutMaker * _Nonnull (^_Nonnull)(CGFloat constant))ma_greaterThanOrEqual;
- (MAAutoLayoutMaker * _Nonnull (^_Nonnull)(CGFloat constant))ma_lessThanOrEqual;
// 倍数
- (MAAutoLayoutMaker * _Nonnull (^_Nonnull)(CGFloat multiplier))multiplier;
// 权重
- (MAAutoLayoutMaker * _Nonnull (^_Nonnull)(UILayoutPriority priority))priority;

- (BOOL)isActive;

- (nonnull NSLayoutConstraint *)active;
- (void)deactivate;
@end

@interface MAAutoLayout : NSObject

- (nonnull instancetype)initWithView:(UIView * _Nonnull)view;

// 基本操作
@property (nonatomic, strong, readonly) MAAutoLayoutMaker * _Nonnull left;
@property (nonatomic, strong, readonly) MAAutoLayoutMaker * _Nonnull top;
@property (nonatomic, strong, readonly) MAAutoLayoutMaker * _Nonnull right;
@property (nonatomic, strong, readonly) MAAutoLayoutMaker * _Nonnull bottom;
@property (nonatomic, strong, readonly) MAAutoLayoutMaker * _Nonnull leading;
@property (nonatomic, strong, readonly) MAAutoLayoutMaker * _Nonnull trailing;
@property (nonatomic, strong, readonly) MAAutoLayoutMaker * _Nonnull width;
@property (nonatomic, strong, readonly) MAAutoLayoutMaker * _Nonnull height;
@property (nonatomic, strong, readonly) MAAutoLayoutMaker * _Nonnull centerX;
@property (nonatomic, strong, readonly) MAAutoLayoutMaker * _Nonnull centerY;
@property (nonatomic, strong, readonly) MAAutoLayoutMaker * _Nonnull baseline;

// 激活
- (void)active;
// 取消
- (void)deactivate;

@end

@interface UIView (MAAutoLayout)

@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_left;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_top;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_right;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_bottom;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_leading;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_trailing;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_width;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_height;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_centerX;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_centerY;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_baseline;

//iOS11 safeArea
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_safeAreaLayoutGuideTop;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_safeAreaLayoutGuideBottom;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_safeAreaLayoutGuideLeft;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_safeAreaLayoutGuideRight;

- (void)ma_makeConstraints:(void(^_Nonnull)(MAAutoLayout * _Nonnull make))make;
- (void)ma_remakeConstraints:(void(^_Nonnull)(MAAutoLayout * _Nonnull make))make;
- (void)ma_removeConstraints;

- (UIEdgeInsets)ma_safeAreaInsets;
+ (UIEdgeInsets)ma_rootSafeAreaInsets;

@end

@interface UIViewController (MAAutoLayout)

@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_topLayoutGuide;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_bottomLayoutGuide;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_topLayoutGuideTop;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_topLayoutGuideBottom;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_bottomLayoutGuideTop;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_bottomLayoutGuideBottom;

@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_safeAreaTopLayoutGuide;
@property (nonatomic, strong, readonly) MAViewAttribute * _Nonnull ma_safeAreaBottomLayoutGuide;

@end


@interface MAAutoLayoutMakers : NSObject

@property (nullable, nonatomic,strong, readonly) NSArray <MAAutoLayoutMaker *>*layoutMarkers;
@property (nullable, nonatomic,strong, readonly) NSArray <NSLayoutConstraint *>*layoutConstraints;
- (nonnull instancetype)initWithFirstItem:(nonnull id)firstItem attributes:(NSArray *_Nonnull)attributes;
// 偏移量
- (MAAutoLayoutMakers * _Nonnull (^_Nonnull)(CGFloat offset))offset;
- (MAAutoLayoutMakers * _Nonnull (^_Nonnull)(UIEdgeInsets insets))insets;

// 关系
- (MAAutoLayoutMakers * _Nonnull (^_Nonnull)(id _Nonnull attr))equalTo;
- (MAAutoLayoutMakers * _Nonnull (^_Nonnull)(id _Nonnull attr))greaterThanOrEqualTo;
- (MAAutoLayoutMakers * _Nonnull (^_Nonnull)(id _Nonnull attr))lessThanOrEqualTo;

// 赋值
- (MAAutoLayoutMakers * _Nonnull (^_Nonnull)(CGFloat constant))ma_equal;
- (MAAutoLayoutMakers * _Nonnull (^_Nonnull)(CGFloat width, CGFloat height))ma_equalSize;
- (MAAutoLayoutMakers * _Nonnull (^_Nonnull)(CGFloat constant))ma_greaterThanOrEqual;
- (MAAutoLayoutMakers * _Nonnull (^_Nonnull)(CGFloat constant))ma_lessThanOrEqual;

- (BOOL)isActive;

- (nonnull NSArray <NSLayoutConstraint *>*)active;
- (void)deactivate;
@end
@interface MAAutoLayout (MAConvenience)

@property (nonatomic, strong, readonly) MAAutoLayoutMakers * _Nonnull leftRight;
@property (nonatomic, strong, readonly) MAAutoLayoutMakers * _Nonnull topBottom;
@property (nonatomic, strong, readonly) MAAutoLayoutMakers * _Nonnull size;
@property (nonatomic, strong, readonly) MAAutoLayoutMakers * _Nonnull center;
@property (nonatomic, strong, readonly) MAAutoLayoutMakers * _Nonnull topLeft;
@property (nonatomic, strong, readonly) MAAutoLayoutMakers * _Nonnull topRight;
@property (nonatomic, strong, readonly) MAAutoLayoutMakers * _Nonnull bottomLeft;
@property (nonatomic, strong, readonly) MAAutoLayoutMakers * _Nonnull bottomRight;
@property (nonatomic, strong, readonly) MAAutoLayoutMakers * _Nonnull edge;
@property (nonatomic, strong, readonly) MAAutoLayoutMakers * _Nonnull topLeftRight;
@property (nonatomic, strong, readonly) MAAutoLayoutMakers * _Nonnull bottomLeftRight;
@property (nonatomic, strong, readonly) MAAutoLayoutMakers * _Nonnull leftTopBottom;
@property (nonatomic, strong, readonly) MAAutoLayoutMakers * _Nonnull rightTopBottom;

@end
