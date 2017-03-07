//
//  HeProtectUserInfoTableCell.h
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"
#import "YLButton.h"

@interface HeProtectUserInfoTableCell : HeBaseTableViewCell
@property(strong,nonatomic)UILabel *baseInfoLabel;
@property(strong,nonatomic)UILabel *addressLabel;
@property(strong,nonatomic)UILabel *defaultLabel;
@property(strong,nonatomic)YLButton *selectBt;
@property(strong,nonatomic)YLButton *editButton;

@property (strong,nonatomic) void(^selectBlock)();
@property (nonatomic,strong) void(^editBlock)();
@property (nonatomic,strong) void(^deleteBlock)();
@end
