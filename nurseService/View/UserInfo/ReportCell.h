//
//  ReportCell.h
//  nurseService
//
//  Created by Tony on 2017/1/18.
//  Copyright © 2017年 iMac. All rights reserved.
//  报告视图的模板

#import <UIKit/UIKit.h>

@interface ReportCell : UIView
//时间标签
@property(strong,nonatomic)UILabel *timeLabel;
//服务内容的标签
@property(strong,nonatomic)UILabel *serviceLabel;
//护士姓名的标签
@property(strong,nonatomic)UILabel *nameLabel;
//所属科室的标签
@property(strong,nonatomic)UILabel *officeLabel;
//地址的标签
@property(strong,nonatomic)UILabel *addressLabel;

/*
 @brief 对视图进行初始化
 @param color 背景图的颜色
 @param frame 视图的框架以及大小
 */
- (id)initViewWithColor:(UIColor *)color frame:(CGRect)frame;
//更新视图的方法
- (void)updateFrame;
//设置视图的箭头
- (void)setArrowImageWithImage:(UIImage *)arrowImage;
//查看报告详情的方法
@property (nonatomic,strong)void(^showReportDetailBlock)();

@end
