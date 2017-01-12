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
        
        CGFloat bgView_W = SCREENWIDTH;
        CGFloat bgView_H = 95;
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, bgView_W, bgView_H)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.userInteractionEnabled = YES;
        [self addSubview:bgView];
//        [bgView.layer setMasksToBounds:YES];
//        bgView.layer.cornerRadius = 4.0;
        
        CGFloat labelX = 10;
        CGFloat labelY = 0;
        CGFloat labelH = 35;
        CGFloat labelW = cellsize.width - 2 * labelX;
        
        UIFont *font = [UIFont systemFontOfSize:15.0];
        baseInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
        baseInfoLabel.backgroundColor = [UIColor clearColor];
        baseInfoLabel.font = font;
        baseInfoLabel.textColor = [UIColor blackColor];
        baseInfoLabel.text = @"小明  男  15768580734";
        [bgView addSubview:baseInfoLabel];
        
        labelY = CGRectGetMaxY(baseInfoLabel.frame)-5;
        addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
        addressLabel.backgroundColor = [UIColor clearColor];
        addressLabel.font = font;
        addressLabel.textColor = [UIColor blackColor];
        addressLabel.text = @"中山西区长乐新村";
        [bgView addSubview:addressLabel];
        
        labelY = CGRectGetMaxY(addressLabel.frame);
        UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, labelY, bgView_W, 1)];
        [bgView addSubview:line1];
        line1.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        
        labelY = CGRectGetMaxY(line1.frame);
        labelH = bgView_H - labelY;
        UIButton *selectBt = [[UIButton alloc] initWithFrame:CGRectMake(10, labelY+(labelH-25)/2.0, 25, 25)];
        [bgView addSubview:selectBt];
        selectBt.backgroundColor = [UIColor clearColor];
        [selectBt setImage:[UIImage imageNamed:@"unselect_box"] forState:UIControlStateNormal];
        [selectBt setImage:[UIImage imageNamed:@"select_box"] forState:UIControlStateSelected];
        [selectBt addTarget:self action:@selector(selectedAction:) forControlEvents:UIControlEventTouchUpInside];
    
        labelX = CGRectGetMaxX(selectBt.frame);
        UILabel *defaultLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, 80, labelH)];
        [bgView addSubview:defaultLabel];
        defaultLabel.backgroundColor = [UIColor clearColor];
        defaultLabel.userInteractionEnabled = YES;
        defaultLabel.text = @"默认信息";
        [defaultLabel setFont:font];
        [defaultLabel setTextColor:[UIColor blackColor]];
        
        labelX = bgView_W - 180;
        UIImageView *editImageView = [[UIImageView alloc] initWithFrame:CGRectMake( labelX, labelY+(labelH-25)/2.0, 25, 25)];
        editImageView.backgroundColor = [UIColor clearColor];
        editImageView.image = [UIImage imageNamed:@"icon_delete"];
        editImageView.userInteractionEnabled = YES;
        [bgView addSubview:editImageView];
        
        labelX = bgView_W - 155;
        UILabel *editLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, 50, labelH)];
        [bgView addSubview:editLabel];
        editLabel.backgroundColor = [UIColor clearColor];
        editLabel.userInteractionEnabled = YES;
        editLabel.text = @"编辑";
        [editLabel setFont:font];
        [editLabel setTextColor:[UIColor blackColor]];
        
        labelX = bgView_W - 95;
        UIImageView *deleteImageView = [[UIImageView alloc] initWithFrame:CGRectMake( labelX, labelY+(labelH-25)/2.0, 25, 25)];
        deleteImageView.backgroundColor = [UIColor clearColor];
        deleteImageView.image = [UIImage imageNamed:@"icon_delete"];
        deleteImageView.userInteractionEnabled = YES;
        [bgView addSubview:deleteImageView];
        
        labelX = bgView_W - 70;
        UILabel *deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, 50, labelH)];
        deleteLabel.backgroundColor = [UIColor clearColor];
        deleteLabel.userInteractionEnabled = YES;
        deleteLabel.text = @"删除";
        [bgView addSubview:deleteLabel];
        [deleteLabel setFont:font];
        [deleteLabel setTextColor:[UIColor blackColor]];
        
        
        
        
    }
    return self;
}

- (void)selectedAction:(UIButton *)sender{
    sender.selected = !sender.selected;
}

@end
