//
//  ReportCell.h
//  nurseService
//
//  Created by Tony on 2017/1/18.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportCell : UIView
@property(strong,nonatomic)UILabel *timeLabel;
@property(strong,nonatomic)UILabel *serviceLabel;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)UILabel *officeLabel;
@property(strong,nonatomic)UILabel *addressLabel;

- (id)initViewWithColor:(UIColor *)color frame:(CGRect)frame;
- (void)updateFrame;
- (void)setArrowImageWithImage:(UIImage *)arrowImage;

@property (nonatomic,strong)void(^showReportDetailBlock)();

@end
