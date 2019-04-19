//
//  ViewController.m
//  MHCropView
//
//  Created by Junky on 2019/4/15.
//  Copyright © 2019年 mh. All rights reserved.
//

#import "ViewController.h"
#import "MHCropView.h"
#import "Ctool.h"

@interface ViewController ()<MHCropViewDelegate>

@property(nonatomic,strong)UIView * sView;

@property(nonatomic,strong)NSMutableArray * cropArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    self.sView.center = self.view.center;
    self.sView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.sView];
    
    self.cropArr = [NSMutableArray arrayWithCapacity:0];
    
    NSArray * arr = @[@"返回",@"进入",@"添加",@"删除",@"多选",@"去清扫"];
    CGFloat width = self.view.frame.size.width/3;
    CGFloat height = 40;
    for (int i = 0; i < arr.count; i ++) {
        NSInteger hang = i / 3;
        NSInteger lie = i % 3;
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(lie * width, hang*height + CGRectGetMaxY(self.sView.frame) + 20, width, height);
        btn.layer.cornerRadius = 4;
        btn.layer.borderWidth = 2;
        btn.layer.borderColor = [UIColor blackColor].CGColor;
        btn.layer.masksToBounds = YES;
        [btn setTitle:arr[i] forState:0];
        [btn setTitleColor:[UIColor blackColor] forState:0];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 2000 + i;
        [self.view addSubview:btn];
    }
}
-(void)mhCropViewSelected:(MHCropView *)crop
{
    for (MHCropView * crop in self.cropArr) {
        crop.isSelected = NO;
    }
    crop.isSelected = YES;
}
-(void)click:(UIButton *)sender
{
    if (sender.tag == 2000) {
        //返回
        for (MHCropView * crop in self.cropArr) {
            crop.isMoreSelectType = NO;
            crop.showDot = NO;
            crop.canHandleClick = NO;
        }
        return;
    }
    if (sender.tag == 2001) {
        //进入
        for (MHCropView * crop in self.cropArr) {
            crop.isMoreSelectType = NO;
            crop.showDot = NO;
            crop.canHandleClick = YES;
        }
        return;
    }
    if (sender.tag == 2002) {
        //添加
        if (self.cropArr.count >= 5) {
            return;
        }
        for (MHCropView * crop in self.cropArr) {
            crop.isSelected = NO;
        }
        NSString * name = [NSString stringWithFormat:@"厨房%ld",self.cropArr.count + 1];
        MHCropView * crop = [[MHCropView alloc] initWithFatherView:self.sView areaName:name type:MHCropTypeNomal];
        crop.delegate = self;
        [self.sView addSubview:crop];
        [self.cropArr addObject:crop];
        return;
    }
    if (sender.tag == 2003) {
        //删除
        NSMutableArray * lArr = [NSMutableArray arrayWithCapacity:0];
        for (MHCropView * crop in self.cropArr) {
            if (crop.isSelected) {
                [crop removeFromSuperview];
            }else{
                [lArr addObject:crop];
            }
        }
        [self.cropArr removeAllObjects];
        [self.cropArr addObjectsFromArray:lArr];
        return;
    }
    if (sender.tag == 2004) {
        //多选
        if ([sender.titleLabel.text isEqualToString:@"多选"]) {
            [sender setTitle:@"非多选" forState:0];
            for (MHCropView * crop in self.cropArr) {
                crop.isMoreSelectType = YES;
            }
        }else{
            [sender setTitle:@"多选" forState:0];
            for (MHCropView * crop in self.cropArr) {
                crop.isMoreSelectType = NO;
            }
        }

        return;
    }
    if (sender.tag == 2005) {
        //去清扫
        [self testLine];
        return;
    }
}
-(void)testLine
{
    NSArray * pointArr;
    for (MHCropView * crop in self.cropArr) {
        if (crop.isSelected) {
            pointArr = [NSArray arrayWithArray:crop.pointArr];
            break;
        }
    }
    
    NSLog(@"%@",pointArr);
    for (int i = 0; i < pointArr.count; i ++) {
        
        int i2 = (i + 1) % pointArr.count;
        
        CGPoint s1 = [pointArr[i] CGPointValue];
        CGPoint e1 = [pointArr[i2] CGPointValue];
        
        for (int j = 0; j < pointArr.count - 3; j ++) {
            int i3 = (i + 2 + j) % pointArr.count;
            int i4 = (i + 3 + j) % pointArr.count;
            
            NSLog(@"(%d===%d)----(%d===%d)",i,i2,i3,i4);
        }
    }
//    for (int i=0; i<detailArray.count-2; i++) {
//
//
//        for (int j = i+1; j<detailArray.count-2; j++) {
//
//            if (i==0&&j==detailArray.count-3) continue;
//
//            CPoint s1 =CPoint([detailArray[i][0] floatValue],[detailArray[i][1] floatValue]);
//
//            CPoint e1 =CPoint([detailArray[i+1][0] floatValue],[detailArray[i+1][1] floatValue]);
//
//            CPoint s2 = CPoint([detailArray[j+1][0] floatValue],[detailArray[j+1][1] floatValue]);
//
//
//            CPoint e2 = CPoint([detailArray[j+2][0] floatValue],[detailArray[j+2][1] floatValue]);
//
//            NSLog(@"(%d===%d)----(%d===%d)",i,i+1,j+1,j+2);
//
//            if (LineIntersects(s1, e1, s2, e2)) {
//
//                NSLog(@"有相交===========");
//
//                return;
//
//            }
//
//
//        }
//
//
//    }
}
@end
