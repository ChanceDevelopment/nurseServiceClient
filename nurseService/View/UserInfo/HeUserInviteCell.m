//
//  HeUserInviteCell.m
//  nurseService
//
//  Created by Tony on 2017/1/19.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeUserInviteCell.h"

@implementation HeUserInviteCell
@synthesize userImage;
@synthesize nameLabel;

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
        CGFloat bgViewY = 10;
        CGFloat bgViewW = cellsize.width - 2 * bgViewX;
        CGFloat bgViewH = cellsize.height - 2 * bgViewY;
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(bgViewX, bgViewY, bgViewW, bgViewH)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.cornerRadius = 5.0;
        bgView.layer.masksToBounds = YES;
        [self addSubview:bgView];
        
        CGFloat userImageX = 10;
        CGFloat userImageY = 5;
        CGFloat userImageW = 50;
        CGFloat userImageH = 50;
        //邀请人头像
        userImage = [[UIImageView alloc] initWithFrame:CGRectMake(userImageX, userImageY, userImageW, userImageH)];
        userImage.image = [UIImage imageNamed:@"defalut_icon"];
        userImage.layer.masksToBounds = YES;
        userImage.layer.cornerRadius = userImageW / 2.0;
        [bgView addSubview:userImage];
        
        CGFloat nameLabelX = CGRectGetMaxX(userImage.frame) + 10;
        CGFloat nameLabelY = userImageY;
        CGFloat nameLabelW = bgViewW - nameLabelX - 10;
        CGFloat nameLabelH = userImageH;
        //邀请人名字
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, nameLabelY, nameLabelW, nameLabelH)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:18.0];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.text = @"11";
        [bgView addSubview:nameLabel];
        
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
