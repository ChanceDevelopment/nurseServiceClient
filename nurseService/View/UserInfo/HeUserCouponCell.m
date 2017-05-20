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
@synthesize headImageView;

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
        CGFloat bgViewH = cellsize.height;
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(bgViewX, bgViewY, bgViewW, bgViewH)];
        bgView.backgroundColor = [UIColor clearColor];
        [self addSubview:bgView];
        [bgView setImage:[UIImage imageNamed:@"icon_coupon_bg"]];
        
        //优惠券banner图
        CGFloat itemX = 10;
        CGFloat itemY = 15;
        CGFloat itemW = 50;
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(itemX, itemY, itemW, itemW)];
        headImageView.backgroundColor = [UIColor clearColor];
        headImageView.layer.masksToBounds = YES;
        headImageView.image = [UIImage imageNamed:@"icon_coupon"];
        headImageView.contentMode = UIViewContentModeScaleAspectFill;
        headImageView.layer.borderWidth = 0.0;
        headImageView.layer.cornerRadius = 40 / 2.0;
        headImageView.layer.masksToBounds = YES;
        [bgView addSubview:headImageView];

        
        CGFloat contentLabelX = CGRectGetMaxX(headImageView.frame);
        CGFloat contentLabelY = 10;
        CGFloat contentLabelW = 200;
        CGFloat contentLabelH = 25;
        
        //优惠券内容
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentLabelX, contentLabelY, contentLabelW, contentLabelH)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.font = [UIFont systemFontOfSize:17.0];
        contentLabel.textColor = [UIColor redColor];
        contentLabel.text = @"11";
        [bgView addSubview:contentLabel];
        
        CGFloat timeLabelX = CGRectGetMaxX(headImageView.frame);
        CGFloat timeLabelY = CGRectGetMaxY(contentLabel.frame);
        CGFloat timeLabelW = bgViewW-timeLabelX-5;
        CGFloat timeLabelH = 50;
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelX, timeLabelY, timeLabelW+5, 1)];
        line.backgroundColor = [UIColor lightGrayColor];
        [bgView addSubview:line];
        
        //有效期
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelX, timeLabelY, timeLabelW, timeLabelH)];
        timeLabel.numberOfLines = 2;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont systemFontOfSize:12.0];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.text = @"11";
        [bgView addSubview:timeLabel];
        
        CGFloat priceLabelX = bgViewW-110;
        CGFloat priceLabelY = 10;
        CGFloat priceLabelW = 100;
        CGFloat priceLabelH = contentLabelH;
        
        //优惠价格
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceLabelX, priceLabelY, priceLabelW, priceLabelH)];
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.font = [UIFont systemFontOfSize:18.0];
        priceLabel.textColor = [UIColor redColor];
        priceLabel.text = @"11";
        priceLabel.textAlignment = NSTextAlignmentRight;
        [bgView addSubview:priceLabel];
        
//        CGFloat conditionLabelX = CGRectGetMaxX(contentLabel.frame);
//        CGFloat conditionLabelY = CGRectGetMaxY(priceLabel.frame);
//        CGFloat conditionLabelW = (bgViewW - 2 * contentLabelX) / 2.0;
//        CGFloat conditionLabelH = contentLabelH;
//        
//        conditionLabel = [[UILabel alloc] initWithFrame:CGRectMake(conditionLabelX, conditionLabelY, conditionLabelW, conditionLabelH)];
//        conditionLabel.backgroundColor = [UIColor clearColor];
//        conditionLabel.font = [UIFont systemFontOfSize:15.0];
//        conditionLabel.textColor = [UIColor redColor];
//        conditionLabel.text = @"11";
//        conditionLabel.textAlignment = NSTextAlignmentRight;
//        [bgView addSubview:conditionLabel];
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
