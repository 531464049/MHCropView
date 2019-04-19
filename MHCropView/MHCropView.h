//
//  MHCropView.h
//  MHCropView
//
//  Created by Junky on 2019/4/15.
//  Copyright © 2019年 mh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MHDotView;
@class MHCropView;

typedef NS_ENUM(NSInteger, MHCropType) {
    MHCropTypeNomal      = 0,  //区域清扫类型
    MHCropTypeForbid     = 1,  //禁区类型
};

@protocol MHCropViewDelegate <NSObject>

@optional
//选中的回调
-(void)mhCropViewSelected:(MHCropView *)crop;

@end

@interface MHCropView : UIView

//默认属性 是否显示圆点 是否可编辑
@property(nonatomic,assign)BOOL showDot;//是否显示拐角圆点 默认yes
@property(nonatomic,assign)BOOL canCrop;//是否可编辑 默认yes

//全局控制属性
@property(nonatomic,assign)BOOL canHandleClick;//是否响应点击事件

//多选状态 属性 是否是多选 是否被选中
@property(nonatomic,assign)BOOL isMoreSelectType;//是否多选状态 默认no
@property(nonatomic,assign)BOOL isSelected;//是否被选中 多选状态下使用

@property(nonatomic,weak)id <MHCropViewDelegate> delegate;
@property(nonatomic,assign,readonly)MHCropType cropType;//只读 区域类型（禁区/区域清扫）

@property(nonatomic,strong)NSMutableArray * pointArr;//坐标点数组

//初始化
-(instancetype)initWithFatherView:(UIView *)fatherView areaName:(nullable NSString *)areaName type:(MHCropType)type;

//修改区域名称
-(void)changeAreaName:(NSString *)areaName;

@end

#pragma mark - 拐点小圆点

@protocol MHDotViewDelegate <NSObject>

@optional
//删除拐点
-(void)mhDotViewDeleteDot:(MHDotView *)dotView;
//增加拐点
-(void)mhDotViewAddDot:(MHDotView *)dotView;
//拐点位置变更
-(void)mhDotView:(MHDotView *)dotView pointChange:(CGPoint)point;

@end

@interface MHDotView : UIView

@property(nonatomic,weak)id <MHDotViewDelegate> delegate;

@property(nonatomic,assign)NSInteger index;//下标
@property(nonatomic,assign)BOOL isAddDot;//是否加号
@property(nonatomic,assign)BOOL isDelDot;//是否减号
@property(nonatomic,assign)BOOL handleCrop;//是否相应手势
//初始化-直接给一个中心点坐标
-(instancetype)initWithCenter:(CGPoint)center;

@end
