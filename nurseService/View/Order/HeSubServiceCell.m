//
//  HeSubServiceCell.m
//  nurseService
//
//  Created by Tony on 2017/1/22.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeSubServiceCell.h"

@implementation HeSubServiceCell
@synthesize serviceNameLabel;
@synthesize serviceButton;

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
    self.backgroundColor = [UIColor whiteColor];
    if (self) {
        CGFloat serviceNameLabelX = 10;
        CGFloat serviceNameLabelY = 0;
        CGFloat serviceNameLabelH = cellsize.height;
        CGFloat serviceNameLabelW = cellsize.width - serviceNameLabelX - 60;
        
        serviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(serviceNameLabelX, serviceNameLabelY, serviceNameLabelW, serviceNameLabelH)];
        serviceNameLabel.backgroundColor = [UIColor blackColor];
        serviceNameLabel.font = [UIFont systemFontOfSize:15.0];
        serviceNameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:serviceNameLabel];
        
        CGFloat serviceButtonW = 20;
        CGFloat serviceButtonH = 20;
        CGFloat serviceButtonX = cellsize.width - serviceButtonW - 20;
        CGFloat serviceButtonY = (cellsize.height - serviceButtonH) / 2.0;
        
        serviceButton = [[UIButton alloc] initWithFrame:CGRectMake(serviceButtonX, serviceButtonY, serviceButtonW, serviceButtonH)];
        [serviceButton setImage:[UIImage imageNamed:@"icon_hook"] forState:UIControlStateSelected];
        [serviceButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//        [serviceButton addTarget:self action:@selector(serviceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:serviceButton];
    }
    return self;
}

- (void)serviceButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
    if (self.selectBlock) {
        self.selectBlock();
    }
}

@end
