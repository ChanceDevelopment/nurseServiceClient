//
//  HeProtectUserInfoTableCell.m
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeProtectUserInfoTableCell.h"

@implementation HeProtectUserInfoTableCell
@synthesize baseInfoLabel;
@synthesize addressLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        CGFloat labelX = 10;
        CGFloat labelY = 10;
        CGFloat labelH = (cellsize.height - 2 * labelY) / 2.0;
        CGFloat labelW = cellsize.width - 2 * labelX;
        
        UIFont *font = [UIFont systemFontOfSize:15.0];
        baseInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
        baseInfoLabel.backgroundColor = [UIColor clearColor];
        baseInfoLabel.font = font;
        baseInfoLabel.textColor = [UIColor blackColor];
        baseInfoLabel.text = @"小明  男  15768580734";
        [self addSubview:baseInfoLabel];
        
        labelY = CGRectGetMaxY(baseInfoLabel.frame);
        addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
        addressLabel.backgroundColor = [UIColor clearColor];
        addressLabel.font = font;
        addressLabel.textColor = [UIColor blackColor];
        addressLabel.text = @"中山西区长乐新村";
        [self addSubview:addressLabel];
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
