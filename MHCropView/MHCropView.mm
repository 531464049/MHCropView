//
//  MHCropView.m
//  MHCropView
//
//  Created by Junky on 2019/4/15.
//  Copyright © 2019年 mh. All rights reserved.
//

#import "MHCropView.h"
#import "Ctool.h"

#define k_margin   10  //拐点与边界间隔
#define k_MaxDotNum 20  //拐点最大数量

@interface MHCropView ()<MHDotViewDelegate>

@property(nonatomic,copy)NSString * areaName;//区域名称
@property(nonatomic,strong)UILabel * nameLab;//区域名称lab
@property(nonatomic,strong)UIImageView * selImage;//多选状态下 选中/非选中图标
@property(nonatomic,strong)UIControl * selControl;//点击控制

@property(nonatomic,strong)UIView * fatherView;//父视图
@property(nonatomic,strong)CAShapeLayer * shapeLayer;//填充区域
@property(nonatomic,strong)NSMutableArray * dotArr;//拐点圆点数组

@end

@implementation MHCropView

-(instancetype)initWithFatherView:(UIView *)fatherView areaName:(NSString *)areaName type:(MHCropType)type
{
    CGFloat width = fatherView.frame.size.width >= 100 ? 100 : fatherView.frame.size.width;
    CGRect frame = CGRectMake((fatherView.frame.size.width - width)/2, (fatherView.frame.size.height - width)/2, width, width);
    self = [super initWithFrame:frame];
    if (self) {
        self.fatherView = fatherView;
        self.areaName = areaName;
        _cropType = type;
        [self initProperty];
    }
    return self;
}
-(void)initProperty
{
    self.multipleTouchEnabled = NO;
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    
    self.showDot = YES;
    self.canCrop = YES;
    self.isMoreSelectType = NO;
    self.isSelected = YES;
    self.canHandleClick = YES;
}
#pragma mark - 加载到父视图时
-(void)didMoveToSuperview
{
    NSLog(@"didMoveToSuperview");
    //初始四个点坐标 相对父视图fatherView
    self.pointArr = [NSMutableArray arrayWithCapacity:0];
    [self.pointArr addObject:[NSValue valueWithCGPoint:[self.fatherView convertPoint:CGPointMake(k_margin, k_margin) fromView:self]]];
    [self.pointArr addObject:[NSValue valueWithCGPoint:[self.fatherView convertPoint:CGPointMake(self.frame.size.width - k_margin, k_margin) fromView:self]]];
    [self.pointArr addObject:[NSValue valueWithCGPoint:[self.fatherView convertPoint:CGPointMake(self.frame.size.width - k_margin, self.frame.size.height - k_margin) fromView:self]]];
    [self.pointArr addObject:[NSValue valueWithCGPoint:[self.fatherView convertPoint:CGPointMake(k_margin, self.frame.size.height - k_margin) fromView:self]]];
    self.dotArr = [NSMutableArray arrayWithCapacity:0];
    
    [self setupUIOperation];
}
#pragma mark - 初始化UI
-(void)setupUIOperation
{
    //名称lab
    self.nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/4*3, 20)];
    self.nameLab.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.nameLab.textColor = [UIColor whiteColor];
    self.nameLab.textAlignment = NSTextAlignmentCenter;
    self.nameLab.font = [UIFont systemFontOfSize:14];
    self.nameLab.text = self.areaName;
    [self addSubview:self.nameLab];
    //选中/非选中图标
    self.selImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.selImage.center = CGPointMake(self.frame.size.width/4, self.frame.size.height/2);
    self.selImage.contentMode = UIViewContentModeScaleAspectFit;
    self.selImage.clipsToBounds = YES;
    self.selImage.hidden = YES;
    [self addSubview:self.selImage];
    //点击控制
    self.selControl = [[UIControl alloc] initWithFrame:self.bounds];
    [self.selControl addTarget:self action:@selector(handleControlClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.selControl];
    
    //初始化layer
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.fillRule = kCAFillRuleNonZero;
    self.shapeLayer.fillColor = [UIColor orangeColor].CGColor;
    self.shapeLayer.strokeColor = [UIColor redColor].CGColor;
    self.shapeLayer.path = [self pathFromPoints].CGPath;
    self.shapeLayer.opacity = 0.5;
    [self.layer addSublayer:self.shapeLayer];
    
    //初始化四个拐点
    for (int i = 0; i < self.pointArr.count; i ++) {
        NSValue * value = self.pointArr[i];
        CGPoint point = [value CGPointValue];
        point = [self convertPoint:point fromView:self.fatherView];
        MHDotView * dot = [[MHDotView alloc] initWithCenter:point];
        dot.delegate = self;
        dot.index = i;
        dot.isAddDot = i == self.pointArr.count - 2;
        dot.isDelDot = i == self.pointArr.count - 1;
        dot.handleCrop = YES;
        [self addSubview:dot];
        [self.dotArr addObject:dot];
    }
}
#pragma mark - 修改区域名称
-(void)changeAreaName:(NSString *)areaName
{
    self.areaName = areaName;
    self.nameLab.text = areaName;
}
#pragma mark - view点击方法
-(void)handleControlClick
{
    if (!self.canHandleClick) {
        return;
    }

    if (self.isMoreSelectType) {
        //多选状态下
        self.isSelected = !self.isSelected;
    }else{
        //非多选状态 代理回调 点击选中当前区域
        if (self.isSelected) {
            //当前就是被选中的
            return;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(mhCropViewSelected:)]) {
            [self.delegate mhCropViewSelected:self];
        }
    }
}
#pragma mark - --------------Set------------
-(void)setCanCrop:(BOOL)canCrop
{
    _canCrop = canCrop;
    for (int i = 0; i < self.dotArr.count; i ++) {
        MHDotView * dot = (MHDotView *)self.dotArr[i];
        dot.handleCrop = canCrop;
    }
}
-(void)setShowDot:(BOOL)showDot
{
    _showDot = showDot;
    for (int i = 0; i < self.dotArr.count; i ++) {
        MHDotView * dot = (MHDotView *)self.dotArr[i];
        dot.hidden = !showDot;
    }
}
-(void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    if (self.isMoreSelectType) {
        if (isSelected) {
            self.selImage.backgroundColor = [UIColor redColor];
        }else{
            self.selImage.backgroundColor = [UIColor cyanColor];
        }
    }else{
        for (int i = 0; i < self.dotArr.count; i ++) {
            MHDotView * dot = (MHDotView *)self.dotArr[i];
            dot.hidden = !isSelected;
        }
    }
}
-(void)setIsMoreSelectType:(BOOL)isMoreSelectType
{
    _isMoreSelectType = isMoreSelectType;
    //多选状态 不显示圆点 不可编辑
    //非多选状态 可编辑
    for (int i = 0; i < self.dotArr.count; i ++) {
        MHDotView * dot = (MHDotView *)self.dotArr[i];
        dot.hidden = YES;
    }
    self.selImage.hidden = !isMoreSelectType;
    //更新图标和名称位置
    if (isMoreSelectType) {
        //self.selImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.selImage.center = CGPointMake(self.frame.size.width/4, self.frame.size.height/2);
        self.nameLab.frame = CGRectMake(CGRectGetMaxX(self.selImage.frame), CGRectGetMinY(self.selImage.frame), self.frame.size.width/2, 20);
    }else{
        self.nameLab.frame = CGRectMake(0, 0, self.frame.size.width/4*3, 20);
        self.nameLab.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
    self.isSelected = NO;
}
#pragma mark - 根据坐标点 创建path
-(UIBezierPath *)pathFromPoints
{
    UIBezierPath * path = [[UIBezierPath alloc] init];
    path.lineWidth = 2.f;
    for (int i = 0; i < self.pointArr.count; i ++) {
        NSValue * value = self.pointArr[i];
        CGPoint point = [value CGPointValue];
        point = [self convertPoint:point fromView:self.fatherView];
        if (i == 0) {
            //设置起点
            [path moveToPoint:point];
        }else{
            //添加子路径
            [path addLineToPoint:point];
        }
    }
    [path closePath];
    return path;
}
#pragma mark - 更新自身frame 拐点位置 填充路径
-(void)updateDotsAndFrame
{
    //更新自身frame
    CGFloat minX = [self.pointArr[0] CGPointValue].x;
    CGFloat minY = [self.pointArr[0] CGPointValue].y;
    CGFloat maxX = [self.pointArr[0] CGPointValue].x;
    CGFloat maxY = [self.pointArr[0] CGPointValue].y;
    for (NSValue * value in self.pointArr) {
        CGPoint point = [value CGPointValue];
        if (point.x <= minX) {
            minX = point.x;
        }
        if (point.x >= maxX) {
            maxX = point.x;
        }
        if (point.y <= minY) {
            minY = point.y;
        }
        if (point.y >= maxY) {
            maxY = point.y;
        }
    }
    self.frame = CGRectMake(minX - k_margin, minY - k_margin, maxX - minX + 2*k_margin, maxY - minY + 2*k_margin);
    self.nameLab.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.selControl.frame = self.bounds;
    
    self.shapeLayer.path = [self pathFromPoints].CGPath;
    
    //更新拐点位置
    for (int i = 0; i < self.dotArr.count; i ++) {
        NSValue * value = self.pointArr[i];
        CGPoint point = [value CGPointValue];
        point = [self convertPoint:point fromView:self.fatherView];
        MHDotView * dot = (MHDotView *)self.dotArr[i];
        dot.center = point;
    }
}
#pragma mark - 更新拐点下标状态
-(void)updateDotsStatus
{
    for (int i = 0; i < self.dotArr.count; i ++) {
        MHDotView * dot = (MHDotView *)self.dotArr[i];
        dot.index = i;
        dot.isAddDot = i == self.pointArr.count - 2;
        dot.isDelDot = i == self.pointArr.count - 1;
    }
}
#pragma mark - 新添加的拐点位置
-(CGPoint)newDotPoint
{
    //选择 + - 两个点中间的位置
    CGPoint aPoint = [[self.pointArr lastObject] CGPointValue];
    CGPoint bPoint = [self.pointArr[self.pointArr.count - 2] CGPointValue];
    CGFloat x = (aPoint.x + bPoint.x) / 2;
    CGFloat y = (aPoint.y + bPoint.y) / 2;
    return CGPointMake(x, y);
}
#pragma mark -----------------MHDotView拐点代理方法----------------
#pragma mark - 添加拐点
-(void)mhDotViewAddDot:(MHDotView *)dotView
{
    if (self.dotArr.count >= k_MaxDotNum) {
        return;
    }
    //添加一个新的坐标点
    CGPoint newPoint = [self newDotPoint];
    MHDotView * dot = [[MHDotView alloc] initWithCenter:newPoint];
    dot.delegate = self;
    dot.handleCrop = YES;
    [self addSubview:dot];
    
    [self.dotArr insertObject:dot atIndex:self.dotArr.count - 1];
    [self.pointArr insertObject:[NSValue valueWithCGPoint:newPoint] atIndex:self.pointArr.count - 1];
    
    [self updateDotsStatus];
    //更新位置信息
    [self updateDotsAndFrame];
}
#pragma mark - 删除拐点
-(void)mhDotViewDeleteDot:(MHDotView *)dotView
{
    //最低三个点
    if (self.dotArr.count <= 3) {
        return;
    }
    
    [self.dotArr removeLastObject];
    [dotView removeFromSuperview];
    [self.pointArr removeLastObject];
    //更新剩余拐点状态
    [self updateDotsStatus];
    //更新位置信息
    [self updateDotsAndFrame];
}
#pragma mark - 拐点位置变更
-(void)mhDotView:(MHDotView *)dotView pointChange:(CGPoint)point
{
    NSValue * value = self.pointArr[dotView.index];
    CGPoint lastPoint = [value CGPointValue];
    lastPoint.x += point.x;
    lastPoint.y += point.y;
    //NSLog(@"%f  ==   %f",lastPoint.x,lastPoint.y);
    //判断是否到达父视图边界
    if (lastPoint.x <= k_margin) {
        lastPoint.x = k_margin;
    }
    if (lastPoint.y <= k_margin) {
        lastPoint.y = k_margin;
    }
    if (lastPoint.x >= self.fatherView.frame.size.width - k_margin) {
        lastPoint.x = self.fatherView.frame.size.width - k_margin;
    }
    if (lastPoint.y >= self.fatherView.frame.size.height - k_margin) {
        lastPoint.y = self.fatherView.frame.size.height - k_margin;
    }
    
    //判断新坐标点下是否有相交直线
    NSMutableArray * newArr = [NSMutableArray arrayWithArray:self.pointArr];
    [newArr replaceObjectAtIndex:dotView.index withObject:[NSValue valueWithCGPoint:lastPoint]];

    BOOL hasIntersects = [self hasIntersectsLine:newArr];
    //是否有相交
    if (hasIntersects) {
        return;
    }else{
        [self.pointArr replaceObjectAtIndex:dotView.index withObject:[NSValue valueWithCGPoint:lastPoint]];
        [self updateDotsAndFrame];
    }
}
-(BOOL)hasIntersectsLine:(NSArray *)pointArr
{
    for (int i = 0; i < pointArr.count; i ++) {

        int i2 = (i + 1) % pointArr.count;

        for (int j = 0; j < pointArr.count - 3; j ++) {
            int i3 = (i + 2 + j) % pointArr.count;
            int i4 = (i + 3 + j) % pointArr.count;

            NSLog(@"(%d===%d)----(%d===%d)",i,i2,i3,i4);
            
            CPoint s1 = CPoint([pointArr[i] CGPointValue].x, [pointArr[i] CGPointValue].y);
            CPoint e1 = CPoint([pointArr[i2] CGPointValue].x, [pointArr[i2] CGPointValue].y);
            CPoint s2 = CPoint([pointArr[i3] CGPointValue].x, [pointArr[i3] CGPointValue].y);
            CPoint e2 = CPoint([pointArr[i4] CGPointValue].x, [pointArr[i4] CGPointValue].y);
            if (LineIntersects(s1, e1, s2, e2)) {
                NSLog(@"有相交===========");
                return YES;
            }
        }
    }
    return NO;
}
@end


#pragma mark --------------------拐点小圆点--------------------
@interface MHDotView ()

@property(nonatomic,strong)UILabel * lab;

@end

@implementation MHDotView

-(instancetype)initWithCenter:(CGPoint)center
{
    CGRect frame = CGRectMake(0, 0, 20, 20);
    self = [super initWithFrame:frame];
    if (self) {
        self.center = center;
        [self setupUI];
        [self addPanGestureRecognizer];
    }
    return self;
}
-(void)setupUI
{
    self.backgroundColor = [UIColor redColor];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    
    self.lab = [[UILabel alloc] initWithFrame:self.bounds];
    self.lab.textColor = [UIColor whiteColor];
    self.lab.textAlignment = NSTextAlignmentCenter;
    self.lab.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.lab];
}
#pragma mark - 添加手势
- (void)addPanGestureRecognizer
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [self addGestureRecognizer:panGesture];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [self addGestureRecognizer:tap];
}
-(void)setIndex:(NSInteger)index
{
    _index = index;
    self.lab.text = [NSString stringWithFormat:@"%ld",_index];
}
-(void)setIsAddDot:(BOOL)isAddDot
{
    _isAddDot = isAddDot;
    if (_isAddDot) {
        self.lab.text = @"+";
    }
}
-(void)setIsDelDot:(BOOL)isDelDot
{
    _isDelDot = isDelDot;
    if (_isDelDot) {
        self.lab.text = @"-";
    }
}
#pragma mark - 点击响应
- (void)handleTapGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    if (!self.handleCrop) {
        return;
    }
    if (self.isAddDot) {
        //添加
        if (self.delegate && [self.delegate respondsToSelector:@selector(mhDotViewAddDot:)]) {
            [self.delegate mhDotViewAddDot:self];
        }
    }
    if (self.isDelDot) {
        //删除
        if (self.delegate && [self.delegate respondsToSelector:@selector(mhDotViewDeleteDot:)]) {
            [self.delegate mhDotViewDeleteDot:self];
        }
    }
}
#pragma mark - 拖拽响应
- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    if (!self.handleCrop) {
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        //NSLog(@"开始拖拽");
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint transPoint = [recognizer translationInView:self];
        //NSLog(@"%f   %f",transPoint.x,transPoint.y);
        if (self.delegate && [self.delegate respondsToSelector:@selector(mhDotView:pointChange:)]) {
            [self.delegate mhDotView:self pointChange:transPoint];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
        
    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled){
        //NSLog(@"结束拖拽");
    }
}
@end
