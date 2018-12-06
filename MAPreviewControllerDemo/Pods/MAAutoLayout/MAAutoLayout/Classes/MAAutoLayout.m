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

@property (nonatomic,strong) NSMutableArray<MAAutoLayoutMaker *> *constraints;
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
