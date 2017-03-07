//
//  HeProtectUserInfoTableCell.m
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeProtectUserInfoTableCell.h"
#import "YLButton.h"

@interface HeProtectUserInfoTableCell()
{
    CGRect editeRect;
    CGRect deleteRect;
}
@end

@implementation HeProtectUserInfoTableCell
@synthesize baseInfoLabel;
@synthesize addressLabel;
@synthesize defaultLabel;
@synthesize selectBt;
@synthesize editButton;


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
        
        CGFloat labelX = 10;
        CGFloat labelY = 0;
        CGFloat labelH = 35;
        CGFloat labelW = cellsize.width - 2 * labelX;
        
        UIFont *font = [UIFont systemFontOfSize:15.0];
        baseInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
        baseInfoLabel.backgroundColor = [UIColor clearColor];
        baseInfoLabel.font = font;
        baseInfoLabel.textColor = [UIColor blackColor];
        [bgView addSubview:baseInfoLabel];
        
        labelY = CGRectGetMaxY(baseInfoLabel.frame)-5;
        addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
        addressLabel.backgroundColor = [UIColor clearColor];
        addressLabel.font = font;
        addressLabel.textColor = [UIColor blackColor];
        
        [bgView addSubview:addressLabel];
        
        labelY = CGRectGetMaxY(addressLabel.frame);
        UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, labelY, bgView_W, 1)];
        [bgView addSubview:line1];
        line1.backgroundColor = [UIColor colorWithWhite:200.0 / 255.0 alpha:1.0];
        
        labelY = CGRectGetMaxY(line1.frame) + 10;
        labelH = bgView_H - labelY;
        selectBt = [[YLButton alloc] init];
        [bgView addSubview:selectBt];
        [selectBt setTitle:@"默认信息" forState:UIControlStateNormal];
        [selectBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        selectBt.backgroundColor = [UIColor clearColor];
        [selectBt setImage:[UIImage imageNamed:@"icon_nocircle"] forState:UIControlStateNormal];
        [selectBt setImage:[UIImage imageNamed:@"icon_circleclick"] forState:UIControlStateSelected];
        [selectBt addTarget:self action:@selector(selectedAction:) forControlEvents:UIControlEventTouchUpInside];
        selectBt.imageRect = CGRectMake(0, 2.5, 25, 25);
        selectBt.titleRect = CGRectMake(30, 0, 60, 30);
        selectBt.titleLabel.font = [UIFont systemFontOfSize:13];
        selectBt.frame = CGRectMake(10, labelY+(labelH-30)/2.0, 90, 30);
    
        
        editButton = [[YLButton alloc] init];
        [bgView addSubview:editButton];
        [editButton setTitle:@"编辑" forState:UIControlStateNormal];
        [editButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        editButton.backgroundColor = [UIColor clearColor];
        [editButton setImage:[UIImage imageNamed:@"icon_edit"] forState:UIControlStateNormal];
        [editButton setImage:[UIImage imageNamed:@"icon_edit"] forState:UIControlStateSelected];
        [editButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        editButton.imageRect = CGRectMake(0, 2.5, 25, 25);
        editButton.titleRect = CGRectMake(30, 0, 30, 30);
        editButton.titleLabel.font = [UIFont systemFontOfSize:13];
        editButton.frame = CGRectMake(SCREENWIDTH - 70, labelY+(labelH-30)/2.0, 60, 30);
        
        labelX = CGRectGetMaxX(selectBt.frame);
        defaultLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, 80, labelH)];
//        [bgView addSubview:defaultLabel];
        defaultLabel.backgroundColor = [UIColor clearColor];
        defaultLabel.userInteractionEnabled = YES;
        
        [defaultLabel setFont:font];
        [defaultLabel setTextColor:[UIColor blackColor]];
        
        labelX = bgView_W - 180;
        UIImageView *editImageView = [[UIImageView alloc] initWithFrame:CGRectMake( labelX, labelY+(labelH-30)/2.0, 30, 30)];
        editImageView.backgroundColor = [UIColor clearColor];
        editImageView.image = [UIImage imageNamed:@"icon_delete"];
        editImageView.userInteractionEnabled = YES;
//        [bgView addSubview:editImageView];
        
//        labelX = bgView_W - 155;
//        UILabel *editLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, 50, labelH)];
////        [bgView addSubview:editLabel];
//        editLabel.backgroundColor = [UIColor clearColor];
//        editLabel.userInteractionEnabled = YES;
//        editLabel.text = @"编辑";
//        [editLabel setFont:font];
//        [editLabel setTextColor:[UIColor blackColor]];
        
//        editeRect   = CGRectMake(bgView_W - 180, labelY, 75, labelH);
        
        labelX = bgView_W - 95;
        UIImageView *deleteImageView = [[UIImageView alloc] initWithFrame:CGRectMake( labelX, labelY+(labelH-30)/2.0, 30, 30)];
        deleteImageView.backgroundColor = [UIColor clearColor];
        deleteImageView.image = [UIImage imageNamed:@"icon_edit"];
        deleteImageView.userInteractionEnabled = YES;
//        [bgView addSubview:deleteImageView];
        
        editeRect   = CGRectMake(labelX, labelY+(labelH-30)/2.0, 30, 30);

        labelX = bgView_W - 70;
        UILabel *deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, 50, labelH)];
        deleteLabel.backgroundColor = [UIColor clearColor];
        deleteLabel.userInteractionEnabled = YES;
        deleteLabel.text = @"编辑";
//        [bgView addSubview:deleteLabel];
        [deleteLabel setFont:font];
        [deleteLabel setTextColor:[UIColor blackColor]];
        
        deleteRect  = CGRectMake(labelX, labelY, 50, labelH);
        
    }
    return self;
}

- (void)selectedAction:(YLButton *)sender{
    if (self.selectBlock){
        self.selectBlock();
    }
    
}

- (void)editButtonClick:(YLButton *)sender
{
    if (self.self.editBlock){
        self.self.editBlock();
    }
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    CGPoint point = [[touches anyObject] locationInView:self];
//    if (CGRectContainsPoint(editeRect, point)) {
//        if (self.editBlock)
//            self.editBlock();
//    }else if (CGRectContainsPoint(deleteRect, point)){
//        if (self.editBlock)
//            self.editBlock();
//    }
//}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //上分割线，
    CGContextSetStrokeColorWithColor(context, ([UIColor clearColor]).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, -1, rect.size.width, 1));
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, ([UIColor colorWithWhite:150.0 / 255.0 alpha:1.0]).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 1));
}

@end
