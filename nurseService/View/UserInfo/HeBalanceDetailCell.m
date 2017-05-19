//
//  HeBalanceDetailCell.m
//  beautyContest
//
//  Created by Tony on 16/10/13.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBalanceDetailCell.h"

@implementation HeBalanceDetailCell
@synthesize moneyLabel;
@synthesize contentLabel;
@synthesize timeLabel;
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
        CGFloat bgViewX = 10;
        CGFloat bgViewY = 5;
        CGFloat bgViewW = SCREENWIDTH - 2 * bgViewX;
        CGFloat bgViewH = cellsize.height - 2 * bgViewY;
        
        self.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(bgViewX, bgViewY, bgViewW, bgViewH)];
        bgView.layer.masksToBounds = YES;
        bgView.layer.cornerRadius = 5.0;
        bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bgView];
        
        //消费或者支出的内容
        UIFont *bigFont = [UIFont systemFontOfSize:17.0];
        CGFloat contentX = 5;
        CGFloat contentY = 10;
        CGFloat contentW = (bgViewW - 2 * contentX) / 2.0;
        CGFloat contentH = bgViewH - 2 * contentY;
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentX, contentY, contentW, contentH)];
        contentLabel.numberOfLines = 0;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.text = @"abc";
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.textColor = [UIColor blackColor];
        [bgView addSubview:contentLabel];
        contentLabel.font = bigFont;
        
        CGFloat userY = 10;
        CGFloat userW = (bgViewW - 2 * contentX) / 2.0;
        CGFloat userX = bgViewW - userW - contentX;
        CGFloat userH = (bgViewH - 2 * userY) / 2.0;
        
        //消费或者支出的金额
        moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(userX, userY, userW, userH)];
        moneyLabel.textAlignment = NSTextAlignmentRight;
        moneyLabel.backgroundColor = [UIColor clearColor];
        moneyLabel.text = @"-10.00";
        moneyLabel.textColor = [UIColor redColor];
        [bgView addSubview:moneyLabel];
        moneyLabel.font = [UIFont systemFontOfSize:18.0];
        
        //消费或者支出的时间
        CGFloat timeY = CGRectGetMaxY(moneyLabel.frame);
        CGFloat timeW = (bgViewW - 2 * contentX) / 2.0;
        CGFloat timeX = userX;
        CGFloat timeH = userH;
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeX, timeY, timeW, timeH)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.text = @"2016";
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.textColor = [UIColor grayColor];
        [bgView addSubview:timeLabel];
        timeLabel.font = [UIFont systemFontOfSize:15.0];
        
        
        
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
