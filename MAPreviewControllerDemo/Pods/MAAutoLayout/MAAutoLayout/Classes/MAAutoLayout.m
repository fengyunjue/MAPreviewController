//
//  MAAutolayout.m
//  MAAutolayout
//
//  Created by admin on 2017/11/28.
//

#import "MAAutoLayout.h"
#import <objc/runtime.h>

@implementation MAViewAttribute

- (id)initWithItem:(id)item layoutAttribute:(NSLayoutAttribute)layoutAttribute{
    self = [super init];
    if (!self) return nil;
    
    _item = item;
    _layoutAttribute = layoutAttribute;
    
    return self;
}

@end

@interface MAAutoLayoutMaker()

@property (nullable, nonatomic,weak) id firstItem;
@property (nonatomic, assign) NSLayoutAttribute firstAttribute;
@property (nullable, nonatomic,weak) id secondItem;
@property (nonatomic, assign) NSLayoutAttribute secondAttribute;
@property (nonatomic, assign) NSLayoutRelation relation;
@property (nonatomic, assign) CGFloat multiplierValue;
@property (nonatomic, assign) CGFloat constant;
@property (nonatomic, assign) UILayoutPriority priorityValue;

@property (nonatomic,strong) NSLayoutConstraint *layoutConstraint;


@end

@implementation MAAutoLayoutMaker

- (instancetype)initWithFirstItem:(id)firstItem firstAttribute:(NSLayoutAttribute)firstAttribute{
    self = [super init];
    if (!self) return nil;
    
    self.firstItem = firstItem;
    self.firstAttribute = firstAttribute;
    self.secondItem = nil;
    self.secondAttribute = NSLayoutAttributeNotAnAttribute;
    self.multiplierValue = 1.0;
    self.constant = 0;
    self.priorityValue = UILayoutPriorityRequired;
    
    return self;
}

- (MAAutoLayoutMaker *(^)(CGFloat))offset{
    return ^id(CGFloat offset){
        self.constant = offset;
        return self;
    };
}

- (MAAutoLayoutMaker * _Nonnull (^)(id _Nonnull))equalTo{
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationEqual);
    };
}
- (MAAutoLayoutMaker * _Nonnull (^)(id _Nonnull))greaterThanOrEqualTo{
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationGreaterThanOrEqual);
    };
}

- (MAAutoLayoutMaker * _Nonnull (^)(id _Nonnull))lessThanOrEqualTo{
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationLessThanOrEqual);
    };
}

- (MAAutoLayoutMaker * _Nonnull (^)(CGFloat))ma_equal{
    return ^id(CGFloat constant) {
        return self.equalToWithRelation(@(constant), NSLayoutRelationEqual);
    };
}

- (MAAutoLayoutMaker * _Nonnull (^)(CGFloat))ma_greaterThanOrEqual{
    return ^id(CGFloat constant) {
        return self.equalToWithRelation(@(constant), NSLayoutRelationGreaterThanOrEqual);
    };
}

- (MAAutoLayoutMaker * _Nonnull (^)(CGFloat))ma_lessThanOrEqual{
    return ^id(CGFloat constant) {
        return self.equalToWithRelation(@(constant), NSLayoutRelationLessThanOrEqual);
    };
}

- (MAAutoLayoutMaker * _Nonnull (^)(UILayoutPriority))priority{
    return ^(UILayoutPriority priority) {
        self.priorityValue = priority;
        return self;
    };
}

- (MAAutoLayoutMaker * _Nonnull (^)(CGFloat))multiplier{
    return ^(CGFloat multiplier) {
        self.multiplierValue = multiplier;
        return self;
    };
}

- (BOOL)isActive{
    return self.layoutConstraint != nil;
}

- (NSLayoutConstraint *)active{
    if (self.layoutConstraint) self.layoutConstraint.active = NO;
    if (self.firstItem) {
        self.layoutConstraint = [NSLayoutConstraint constraintWithItem:self.firstItem attribute:self.firstAttribute relatedBy:self.relation toItem:self.secondItem attribute:self.secondAttribute multiplier:self.multiplierValue constant:self.constant];
        self.layoutConstraint.priority = self.priorityValue;
        self.layoutConstraint.active = YES;
    }
    return self.layoutConstraint;
}

- (void)deactivate{
    [self.layoutConstraint setActive:NO];
    self.layoutConstraint = nil;
}

#pragma mark private
- (MAAutoLayoutMaker * (^)(id, NSLayoutRelation))equalToWithRelation {
    return ^id(id attribute, NSLayoutRelation relation) {
        self.relation = relation;
        if ([attribute isKindOfClass:[UIView class]]) {
            self.secondItem = attribute;
            self.secondAttribute = self.firstAttribute;
        }else if ([attribute isKindOfClass:[MAViewAttribute class]]){
            self.secondItem = ((MAViewAttribute *)attribute).item;
            self.secondAttribute = ((MAViewAttribute *)attribute).layoutAttribute;
        }else if ([attribute isKindOfClass:[NSNumber class]]){
            self.secondItem = nil;
            self.secondAttribute = NSLayoutAttributeNotAnAttribute;
            self.constant = ((NSNumber *)attribute).floatValue;
        }else{
            NSAssert(attribute, @"格式不正确,必须是UIView或MAAutoLayoutMaker或NSNumber");
        }
        self.relation = relation;
        return self;
    };
}

@end

@interface MAAutoLayout()

@property (nonatomic,strong) NSMutableArray<id> *constraints;
@property (nonatomic,weak) id view;

@end

@implementation MAAutoLayout

- (id)initWithView:(UIView *)view{
    self = [super init];
    if (!self) return nil;
    
    self.view = view;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    self.constraints = [NSMutableArray array];
    return self;
}

#pragma mark - standard Attributes
- (MAAutoLayoutMaker *)left {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeft];
}

- (MAAutoLayoutMaker *)top {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTop];
}

- (MAAutoLayoutMaker *)right {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeRight];
}

- (MAAutoLayoutMaker *)bottom {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBottom];
}

- (MAAutoLayoutMaker *)leading {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeLeading];
}

- (MAAutoLayoutMaker *)trailing {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeTrailing];
}

- (MAAutoLayoutMaker *)width {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeWidth];
}

- (MAAutoLayoutMaker *)height {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeHeight];
}

- (MAAutoLayoutMaker *)centerX {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterX];
}

- (MAAutoLayoutMaker *)centerY {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeCenterY];
}

- (MAAutoLayoutMaker *)baseline {
    return [self addConstraintWithLayoutAttribute:NSLayoutAttributeBaseline];
}

- (MAAutoLayoutMaker *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    MAAutoLayoutMaker *maker = [[MAAutoLayoutMaker alloc] initWithFirstItem:self.view firstAttribute:layoutAttribute];
    [self.constraints addObject:maker];
    return maker;
}

- (void)active{
    for (MAAutoLayoutMaker *maker in self.constraints) {
        if (!maker.isActive) {
            [maker active];
        }
    }
}

- (void)deactivate{
    [self.constraints makeObjectsPerformSelector:@selector(deactivate)];
    [self.constraints removeAllObjects];
}

@end

@implementation UIView (MAAutoLayout)

static char kInstalledMAAutoLayoutKey;

- (MAAutoLayout *)ma_layout {
    MAAutoLayout *autolayout = objc_getAssociatedObject(self, &kInstalledMAAutoLayoutKey);
    if (!autolayout) {
        autolayout = [[MAAutoLayout alloc] initWithView:self];
        objc_setAssociatedObject(self, &kInstalledMAAutoLayoutKey, autolayout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return autolayout;
}

- (void)ma_makeConstraints:(void (^)(MAAutoLayout *))make{
    make(self.ma_layout);
    [self.ma_layout active];
}

- (void)ma_remakeConstraints:(void (^)(MAAutoLayout * _Nonnull))make{
    [self.ma_layout deactivate];
    [self ma_makeConstraints:make];
}

- (void)ma_removeConstraints{
    [self.ma_layout deactivate];
}

- (MAViewAttribute *)ma_left{
    return [self ma_viewAttribute:NSLayoutAttributeLeft];
}

- (MAViewAttribute *)ma_top{
    return [self ma_viewAttribute:NSLayoutAttributeTop];
}

- (MAViewAttribute *)ma_right{
    return [self ma_viewAttribute:NSLayoutAttributeRight];
}

- (MAViewAttribute *)ma_bottom{
    return [self ma_viewAttribute:NSLayoutAttributeBottom];
}

- (MAViewAttribute *)ma_leading{
    return [self ma_viewAttribute:NSLayoutAttributeLeading];
}

- (MAViewAttribute *)ma_trailing{
    return [self ma_viewAttribute:NSLayoutAttributeTrailing];
}

- (MAViewAttribute *)ma_width{
    return [self ma_viewAttribute:NSLayoutAttributeWidth];
}

- (MAViewAttribute *)ma_height{
    return [self ma_viewAttribute:NSLayoutAttributeHeight];
}

- (MAViewAttribute *)ma_centerX{
    return [self ma_viewAttribute:NSLayoutAttributeCenterX];
}

- (MAViewAttribute *)ma_centerY{
    return [self ma_viewAttribute:NSLayoutAttributeCenterY];
}

- (MAViewAttribute *)ma_baseline{
    return [self ma_viewAttribute:NSLayoutAttributeBaseline];
}

#pragma mark - iOS11 safeArea
- (MAViewAttribute *)ma_safeAreaLayoutGuideTop{
    return [self ma_safeAreaViewAttribute:NSLayoutAttributeTop];
}

- (MAViewAttribute *)ma_safeAreaLayoutGuideBottom{
    return [self ma_safeAreaViewAttribute:NSLayoutAttributeBottom];
}

- (MAViewAttribute *)ma_safeAreaLayoutGuideLeft{
    return [self ma_safeAreaViewAttribute:NSLayoutAttributeLeft];
}

- (MAViewAttribute *)ma_safeAreaLayoutGuideRight{
    return [self ma_safeAreaViewAttribute:NSLayoutAttributeRight];
}

- (UIEdgeInsets)ma_safeAreaInsets{
    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        safeInsets = self.safeAreaInsets;
    }
#endif
    return safeInsets;
}

+ (UIEdgeInsets)ma_rootSafeAreaInsets{
    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        safeInsets = [[UIApplication sharedApplication] delegate].window.safeAreaInsets;
    }
#endif
    return safeInsets;
}

#pragma mark - private
- (MAViewAttribute *)ma_viewAttribute:(NSLayoutAttribute)layoutAttribute {
    return [[MAViewAttribute alloc] initWithItem:self layoutAttribute:layoutAttribute];
}

- (MAViewAttribute *)ma_safeAreaViewAttribute:(NSLayoutAttribute)layoutAttribute {
    id item = self;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        item = self.safeAreaLayoutGuide;
    }
#endif
    return [[MAViewAttribute alloc] initWithItem:item layoutAttribute:layoutAttribute];
}

@end

@implementation UIViewController (MAAutoLayout)

- (MAViewAttribute *)ma_topLayoutGuide{
    return [self ma_topLayoutGuideBottom];
}

- (MAViewAttribute *)ma_bottomLayoutGuide{
    return [self ma_bottomLayoutGuideTop];
}

- (MAViewAttribute *)ma_topLayoutGuideTop{
    return [[MAViewAttribute alloc] initWithItem:self.topLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}

- (MAViewAttribute *)ma_topLayoutGuideBottom{
    return [[MAViewAttribute alloc] initWithItem:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}

- (MAViewAttribute *)ma_bottomLayoutGuideTop{
    return [[MAViewAttribute alloc] initWithItem:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}

- (MAViewAttribute *)ma_bottomLayoutGuideBottom{
    return [[MAViewAttribute alloc] initWithItem:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}

- (MAViewAttribute *)ma_safeAreaTopLayoutGuide{
    id item = self.topLayoutGuide;
    NSLayoutAttribute attribute = NSLayoutAttributeBottom;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        item = self.view.safeAreaLayoutGuide;
        attribute = NSLayoutAttributeTop;
    }
#endif
    return [[MAViewAttribute alloc] initWithItem:item layoutAttribute:attribute];
}

- (MAViewAttribute *)ma_safeAreaBottomLayoutGuide{
    id item = self.bottomLayoutGuide;
    NSLayoutAttribute attribute = NSLayoutAttributeTop;
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        item = self.view.safeAreaLayoutGuide;
        attribute = NSLayoutAttributeBottom;
    }
#endif
    return [[MAViewAttribute alloc] initWithItem:item layoutAttribute:attribute];
}

@end



@interface MAAutoLayoutMakers()

@property (nullable, nonatomic,weak) id firstItem;
@property (nonatomic, strong) NSArray *attributes;
@property (nullable, nonatomic,weak) id secondItem;
@property (nonatomic, assign) NSLayoutRelation relation;
@property (nonatomic, assign) UIEdgeInsets  insetsValue;
@property (nonatomic, assign) UILayoutPriority priorityValue;

@property (nonatomic,strong) NSArray <NSLayoutConstraint *>*layoutConstraints;
@property (nonatomic,strong) NSArray <MAAutoLayoutMaker *>*layoutMarkers;


@end

@implementation MAAutoLayoutMakers

- (instancetype)initWithFirstItem:(id)firstItem attributes:(NSArray *)attributes {
    self = [super init];
    if (!self) return nil;
    
    self.firstItem = firstItem;
    self.attributes = attributes;
    self.secondItem = nil;
    self.insetsValue = UIEdgeInsetsZero;
    self.priorityValue = UILayoutPriorityRequired;
    
    return self;
}

- (MAAutoLayoutMakers *(^)(CGFloat))offset{
    return ^id(CGFloat offset){
        self.insetsValue = UIEdgeInsetsMake(offset, offset, offset, offset);
        return self;
    };
}

- (MAAutoLayoutMakers * _Nonnull (^)(UIEdgeInsets))insets{
    return ^id(UIEdgeInsets insets){
        self.insetsValue = insets;
        return self;
    };
}

- (MAAutoLayoutMakers * _Nonnull (^)(id _Nonnull))equalTo{
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationEqual);
    };
}
- (MAAutoLayoutMakers * _Nonnull (^)(id _Nonnull))greaterThanOrEqualTo{
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationGreaterThanOrEqual);
    };
}

- (MAAutoLayoutMakers * _Nonnull (^)(id _Nonnull))lessThanOrEqualTo{
    return ^id(id attribute) {
        return self.equalToWithRelation(attribute, NSLayoutRelationLessThanOrEqual);
    };
}

- (MAAutoLayoutMakers * _Nonnull (^)(CGFloat))ma_equal{
    return ^id(CGFloat constant) {
        return self.equalToWithRelation(@(constant), NSLayoutRelationEqual);
    };
}

- (MAAutoLayoutMakers * _Nonnull (^)(CGFloat, CGFloat))ma_equalSize{
    return ^id(CGFloat width, CGFloat height) {
        return self.equalToWithRelation([NSValue valueWithCGSize:CGSizeMake(width, height)], NSLayoutRelationEqual);
    };
}

- (MAAutoLayoutMakers * _Nonnull (^)(CGFloat))ma_greaterThanOrEqual{
    return ^id(CGFloat constant) {
        return self.equalToWithRelation(@(constant), NSLayoutRelationGreaterThanOrEqual);
    };
}

- (MAAutoLayoutMakers * _Nonnull (^)(CGFloat))ma_lessThanOrEqual{
    return ^id(CGFloat constant) {
        return self.equalToWithRelation(@(constant), NSLayoutRelationLessThanOrEqual);
    };
}

- (MAAutoLayoutMakers * _Nonnull (^)(UILayoutPriority))priority{
    return ^(UILayoutPriority priority) {
        self.priorityValue = priority;
        return self;
    };
}

- (BOOL)isActive{
    return self.layoutConstraints.count > 0;
}

- (NSArray<NSLayoutConstraint *> *)active{
    if (self.layoutConstraints.count > 0) {
        [self.layoutConstraints makeObjectsPerformSelector:@selector(setActive:) withObject:@(NO)];
    }
    if (self.firstItem) {
        NSMutableArray *constraints = [NSMutableArray arrayWithCapacity:self.attributes.count];
        for (NSInteger i = 0; i < self.attributes.count; i++) {
            NSLayoutAttribute attribute = [self.attributes[i] integerValue];
            CGFloat constant = 0;
            if (attribute == NSLayoutAttributeTop || attribute == NSLayoutAttributeWidth) {
                constant = self.insetsValue.top;
            }else if (attribute == NSLayoutAttributeLeft || attribute == NSLayoutAttributeHeight) {
                constant = self.insetsValue.left;
            }else if (attribute == NSLayoutAttributeRight) {
                constant = self.insetsValue.right;
            }else if (attribute == NSLayoutAttributeBottom) {
                constant = self.insetsValue.bottom;
            }else{
                constant = self.insetsValue.top;
            }
            NSLayoutConstraint *layoutConstraint = [NSLayoutConstraint constraintWithItem:self.firstItem attribute:attribute relatedBy:self.relation toItem:self.secondItem attribute:attribute multiplier:1.0f constant:constant];
            layoutConstraint.priority = self.priorityValue;
            layoutConstraint.active = YES;
            [constraints addObject:layoutConstraint];
        }
        self.layoutConstraints = constraints;
    }
    return self.layoutConstraints;
}

- (void)deactivate{
    for (NSLayoutConstraint *layoutConstraint in self.layoutConstraints) {
        layoutConstraint.active = NO;
    }
    self.layoutConstraints = nil;
}

#pragma mark private
- (MAAutoLayoutMakers * (^)(id, NSLayoutRelation))equalToWithRelation {
    return ^id(id attribute, NSLayoutRelation relation) {
        if ([attribute isKindOfClass:[UIView class]]) {
            self.secondItem = attribute;
        }else if ([attribute isKindOfClass:[NSNumber class]]){
            self.secondItem = nil;
            self.insetsValue = UIEdgeInsetsMake(((NSNumber *)attribute).floatValue, ((NSNumber *)attribute).floatValue, 0, 0);
        }else if ([attribute isKindOfClass:[NSValue class]]) {
            self.secondItem = nil;
            CGSize size = [(NSValue *)attribute CGSizeValue];
            self.insetsValue = UIEdgeInsetsMake(size.width, size.height, 0, 0);
        }else{
            NSAssert(attribute, @"格式不正确,必须是UIView或NSNumber");
        }
        self.relation = relation;
        return self;
    };
}

@end

@implementation MAAutoLayout (MAConvenience)
- (MAAutoLayoutMakers *)addConstraintWithLayoutAttributes:(NSArray *)attributes {
    MAAutoLayoutMakers *maker = [[MAAutoLayoutMakers alloc] initWithFirstItem:self.view attributes:attributes];
    [self.constraints addObject:maker];
    return maker;
}
-(MAAutoLayoutMakers *)leftRight {
    return [self addConstraintWithLayoutAttributes:@[@(NSLayoutAttributeLeft),@(NSLayoutAttributeRight)]];
}
-(MAAutoLayoutMakers *)topBottom {
    return [self addConstraintWithLayoutAttributes:@[@(NSLayoutAttributeTop),@(NSLayoutAttributeBottom)]];
}
-(MAAutoLayoutMakers *)size {
    return [self addConstraintWithLayoutAttributes:@[@(NSLayoutAttributeWidth),@(NSLayoutAttributeHeight)]];
}
-(MAAutoLayoutMakers *)center {
    return [self addConstraintWithLayoutAttributes:@[@(NSLayoutAttributeCenterX),@(NSLayoutAttributeCenterY)]];
}
- (MAAutoLayoutMakers *)topLeft{
    return [self addConstraintWithLayoutAttributes:@[@(NSLayoutAttributeTop),@(NSLayoutAttributeLeft)]];
}
-(MAAutoLayoutMakers *)topRight {
    return [self addConstraintWithLayoutAttributes:@[@(NSLayoutAttributeTop),@(NSLayoutAttributeRight)]];
}
-(MAAutoLayoutMakers *)bottomLeft {
    return [self addConstraintWithLayoutAttributes:@[@(NSLayoutAttributeBottom),@(NSLayoutAttributeLeft)]];
    
}
-(MAAutoLayoutMakers *)bottomRight {
    return [self addConstraintWithLayoutAttributes:@[@(NSLayoutAttributeBottom),@(NSLayoutAttributeRight)]];
    
}
-(MAAutoLayoutMakers *)edge {
    return [self addConstraintWithLayoutAttributes:@[@(NSLayoutAttributeTop),@(NSLayoutAttributeLeft),@(NSLayoutAttributeRight),@(NSLayoutAttributeBottom)]];
}
-(MAAutoLayoutMakers *)topLeftRight {
    return [self addConstraintWithLayoutAttributes:@[@(NSLayoutAttributeTop),@(NSLayoutAttributeLeft),@(NSLayoutAttributeRight)]];
}
-(MAAutoLayoutMakers *)bottomLeftRight {
    return [self addConstraintWithLayoutAttributes:@[@(NSLayoutAttributeLeft),@(NSLayoutAttributeBottom),@(NSLayoutAttributeRight)]];
}
-(MAAutoLayoutMakers *)leftTopBottom {
    return [self addConstraintWithLayoutAttributes:@[@(NSLayoutAttributeLeft),@(NSLayoutAttributeTop),@(NSLayoutAttributeBottom)]];
}
-(MAAutoLayoutMakers *)rightTopBottom {
    return [self addConstraintWithLayoutAttributes:@[@(NSLayoutAttributeRight),@(NSLayoutAttributeTop),@(NSLayoutAttributeBottom)]];
}
@end
