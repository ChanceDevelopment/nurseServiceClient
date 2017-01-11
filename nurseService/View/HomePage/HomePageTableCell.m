//
//  HomePageTableCell.m
//  nurseService
//
//  Created by HeDongMing on 2017/1/8.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HomePageTableCell.h"

@implementation HomePageTableCell
@synthesize bgImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        CGFloat bgImageX = 10;
        CGFloat bgImageY = 5;
        CGFloat bgImageW = cellsize.width - 2 *bgImageX;
        CGFloat bgImageH = cellsize.height - 2 * bgImageY;
        bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index2"]];
        bgImage.frame = CGRectMake(bgImageX, bgImageY, bgImageW, bgImageH);
        bgImage.layer.masksToBounds = YES;
        bgImage.layer.cornerRadius = 5.0;
        bgImage.contentMode = UIViewContentModeScaleAspectFill;
        bgImage.layer.borderColor = [UIColor clearColor].CGColor;
        [self.contentView addSubview:bgImage];
        
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
