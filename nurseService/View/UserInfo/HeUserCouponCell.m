//
//  HeUserCouponCell.m
//  nurseService
//
//  Created by Tony on 2017/1/19.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeUserCouponCell.h"

@implementation HeUserCouponCell
@synthesize contentLabel;
@synthesize timeLabel;
@synthesize priceLabel;
@synthesize conditionLabel;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        self.backgroundColor = RGB(237, 237, 237, 1);
        CGFloat bgViewX = 10;
        CGFloat bgViewY = 5;
        CGFloat bgViewW = cellsize.width - 2 * bgViewX;
        CGFloat bgViewH = cellsize.height - 2 * bgViewY;
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(bgViewX, bgViewY, bgViewW, bgViewH)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.cornerRadius = 5.0;
        bgView.layer.masksToBounds = YES;
        [self addSubview:bgView];
        
        CGFloat contentLabelX = 10;
        CGFloat contentLabelY = 10;
        CGFloat contentLabelW = (bgViewW - 2 * contentLabelX) / 2.0;
        CGFloat contentLabelH = (bgViewH - 2 * contentLabelY) / 2.0;
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentLabelX, contentLabelY, contentLabelW, contentLabelH)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.font = [UIFont systemFontOfSize:17.0];
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.text = @"11";
        [bgView addSubview:contentLabel];
        
        CGFloat timeLabelX = 10;
        CGFloat timeLabelY = CGRectGetMaxY(contentLabel.frame);
        CGFloat timeLabelW = (bgViewW - 2 * contentLabelX) / 2.0;
        CGFloat timeLabelH = contentLabelH;
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelX, timeLabelY, timeLabelW, timeLabelH)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont systemFontOfSize:12.0];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.text = @"11";
        [bgView addSubview:timeLabel];
        
        CGFloat priceLabelX = CGRectGetMaxX(contentLabel.frame);
        CGFloat priceLabelY = 10;
        CGFloat priceLabelW = (bgViewW - 2 * contentLabelX) / 2.0;
        CGFloat priceLabelH = contentLabelH;
        
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceLabelX, priceLabelY, priceLabelW, priceLabelH)];
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.font = [UIFont systemFontOfSize:18.0];
        priceLabel.textColor = [UIColor redColor];
        priceLabel.text = @"11";
        priceLabel.textAlignment = NSTextAlignmentRight;
        [bgView addSubview:priceLabel];
        
        CGFloat conditionLabelX = CGRectGetMaxX(contentLabel.frame);
        CGFloat conditionLabelY = CGRectGetMaxY(priceLabel.frame);
        CGFloat conditionLabelW = (bgViewW - 2 * contentLabelX) / 2.0;
        CGFloat conditionLabelH = contentLabelH;
        
        conditionLabel = [[UILabel alloc] initWithFrame:CGRectMake(conditionLabelX, conditionLabelY, conditionLabelW, conditionLabelH)];
        conditionLabel.backgroundColor = [UIColor clearColor];
        conditionLabel.font = [UIFont systemFontOfSize:15.0];
        conditionLabel.textColor = [UIColor redColor];
        conditionLabel.text = @"11";
        conditionLabel.textAlignment = NSTextAlignmentRight;
        [bgView addSubview:conditionLabel];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //上分割线，
    CGContextSetStrokeColorWithColor(context, ([UIColor clearColor]).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, -1, rect.size.width, 1));
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, ([UIColor clearColor]).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 1));
}

@end
