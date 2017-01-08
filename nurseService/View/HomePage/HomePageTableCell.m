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
        bgImage.layer.borderColor = [UIColor clearColor].CGColor;
        [self.contentView addSubview:bgImage];
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
