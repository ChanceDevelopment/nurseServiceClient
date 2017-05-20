//
//  HeBaseTableViewCell.m
//  huayoutong
//
//  Created by Tony on 16/3/31.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//  基本列表视图模板

#import "HeBaseTableViewCell.h"

@implementation HeBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
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
    CGContextSetStrokeColorWithColor(context, ([UIColor colorWithWhite:200.0 / 255.0 alpha:1.0]).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 1));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
