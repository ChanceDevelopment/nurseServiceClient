//
//  ReportCell.m
//  nurseService
//
//  Created by Tony on 2017/1/18.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "ReportCell.h"
#import "MLLabel+Size.h"

@implementation ReportCell
@synthesize timeLabel;
@synthesize nameLabel;
@synthesize officeLabel;
@synthesize addressLabel;
@synthesize serviceLabel;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initViewWithColor:(UIColor *)color frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat timeLabelX = 10;
        CGFloat timeLabelY = 5;
        CGFloat timeLabelW = 80;
        CGFloat timeLabelH = 50;
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelX, timeLabelY, timeLabelW, timeLabelH)];
        timeLabel.text = @"2016-01-09 10:09";
        timeLabel.font = [UIFont systemFontOfSize:13.0];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.numberOfLines = 3;
        [self addSubview:timeLabel];
        
        CGFloat sepLineX = CGRectGetMaxX(timeLabel.frame) + 5;
        CGFloat sepLineY = 0;
        CGFloat sepLineH = frame.size.height;
        CGFloat sepLineW = 1;
        
        UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(sepLineX, sepLineY, sepLineW, sepLineH)];
        sepLine.backgroundColor = color;
        [self addSubview:sepLine];
        
        CGFloat dotX = 0;
        CGFloat dotY = 0;
        CGFloat dotW = 7;
        CGFloat dotH = 7;
        
        UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(dotX, dotY, dotW, dotH)];
        CGPoint dotCenter = dot.center;
        dotCenter.x = sepLine.center.x;
        dotCenter.y = timeLabel.center.y;
        dot.center = dotCenter;
        dot.backgroundColor = color;
        [self addSubview:dot];
        
        CGFloat rightViewX = CGRectGetMaxX(timeLabel.frame) + 10;
        CGFloat rightViewY = timeLabelY;
        CGFloat rightViewW = frame.size.width - rightViewX - 10;
        CGFloat rightViewH = frame.size.height - 2 * rightViewY;
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(rightViewX, rightViewY, rightViewW, rightViewH)];
        rightView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        [self addSubview:rightView];
        
        CGFloat arrowImageViewX = 0;
        CGFloat arrowImageViewH = 25;
        CGFloat arrowImageViewY = timeLabel.center.y - arrowImageViewH / 2.0 - timeLabelY;
        CGFloat arrowImageViewW = 25;
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_left_arrow"]];
        arrowImageView.tag = 2000;
        arrowImageView.frame = CGRectMake(arrowImageViewX, arrowImageViewY, arrowImageViewW, arrowImageViewH);
        [rightView addSubview:arrowImageView];
        
        CGFloat titleViewX = arrowImageViewW;
        CGFloat titleViewH = arrowImageViewH + 10;
        CGFloat titleViewW = rightViewW - titleViewX;
        CGFloat titleViewY = arrowImageView.center.y - titleViewH / 2.0;
        
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(titleViewX, titleViewY, titleViewW, titleViewH)];
        titleView.backgroundColor = color;
        [rightView addSubview:titleView];
        
        serviceLabel = [[UILabel alloc] initWithFrame:titleView.bounds];
        serviceLabel.font = [UIFont systemFontOfSize:15.0];
        serviceLabel.backgroundColor = [UIColor clearColor];
        serviceLabel.text = @"护理";
        serviceLabel.textColor = [UIColor whiteColor];
        [titleView addSubview:serviceLabel];
        
        CGFloat contentViewX = titleViewX;
        CGFloat contentViewY = CGRectGetMaxY(titleView.frame);
        CGFloat contentViewW = titleViewW;
        CGFloat contentViewH = rightViewH - contentViewY;
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(contentViewX, contentViewY, contentViewW, contentViewH)];
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.tag = 100;
        [rightView addSubview:contentView];
        
        CGFloat nameLabelX = 10;
        CGFloat nameLabelH = 30;
        CGFloat nameLabelY = (contentView.frame.size.height - nameLabelH * 2) / 2.0;
        CGFloat nameLabelW = contentViewW - 2 * nameLabelX;
        
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, nameLabelY, nameLabelW, nameLabelH)];
        nameLabel.text = @"里";
        nameLabel.font = [UIFont systemFontOfSize:16.0];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        [contentView addSubview:nameLabel];
        
        officeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX + 30, nameLabelY + 3, nameLabelW, nameLabelH - 3)];
        officeLabel.text = @"科室:测试";
        officeLabel.font = [UIFont systemFontOfSize:12.0];
        officeLabel.textColor = [UIColor blackColor];
        officeLabel.backgroundColor = [UIColor clearColor];
        [contentView addSubview:officeLabel];
        
        CGFloat iconX = nameLabelX;
        CGFloat iconH = 15;
        CGFloat iconY = CGRectGetMaxY(nameLabel.frame) + 7.5;
        CGFloat iconW = 15;
        
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_address"]];
        icon.frame = CGRectMake(iconX, iconY, iconW, iconH);
        [contentView addSubview:icon];
        
        CGFloat addressLabelX = CGRectGetMaxX(icon.frame) + 3;
        CGFloat addressLabelY = CGRectGetMaxY(nameLabel.frame);
        CGFloat addressLabelW = contentViewW - addressLabelX - 10;
        CGFloat addressLabelH = nameLabelH;
        
        addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(addressLabelX, addressLabelY, addressLabelW, addressLabelH)];
        addressLabel.text = @"广东省中医院";
        addressLabel.numberOfLines = 2;
        addressLabel.font = [UIFont systemFontOfSize:12.0];
        addressLabel.textColor = [UIColor blackColor];
        addressLabel.backgroundColor = [UIColor clearColor];
        [contentView addSubview:addressLabel];
        
        rightView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanReportDetail)];
        [rightView addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)scanReportDetail
{
    if (self.showReportDetailBlock) {
        self.showReportDetailBlock();
    }
}

- (void)setArrowImageWithImage:(UIImage *)arrowImage
{
    UIImageView *arrowImageView = [self viewWithTag:2000];
    arrowImageView.image = arrowImage;
}

- (void)updateFrame
{
    CGRect frame = officeLabel.frame;
    frame.origin.x = nameLabel.frame.origin.x + ([MLLabel getViewSizeByString:nameLabel.text maxWidth:100 font:nameLabel.font].width + 10);
    officeLabel.frame = frame;
}

@end
