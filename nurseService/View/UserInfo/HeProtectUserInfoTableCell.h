//
//  HeProtectUserInfoTableCell.h
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//  受护人的信息视图模板

#import "HeBaseTableViewCell.h"
#import "YLButton.h"

@interface HeProtectUserInfoTableCell : HeBaseTableViewCell
//基本信息标签
@property(strong,nonatomic)UILabel *baseInfoLabel;
//地址标签
@property(strong,nonatomic)UILabel *addressLabel;
//是否默认受护人
@property(strong,nonatomic)UILabel *defaultLabel;
//选择受护人按钮
@property(strong,nonatomic)YLButton *selectBt;
//编辑信息按钮
@property(strong,nonatomic)YLButton *editButton;

//选择改变默认受护人
@property (strong,nonatomic) void(^selectBlock)();
//编辑受护人信息
@property (nonatomic,strong) void(^editBlock)();
//删除受护人
@property (nonatomic,strong) void(^deleteBlock)();
@end
