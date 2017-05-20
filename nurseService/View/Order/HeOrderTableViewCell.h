//
//  HeOrderTableViewCell.h
//  nurseService
//
//  Created by HeDongMing on 2017/1/8.
//  Copyright © 2017年 iMac. All rights reserved.
//  总的订单列表

#import "HeBaseTableViewCell.h"

@interface HeOrderTableViewCell : HeBaseTableViewCell
//订单的服务内容
@property (nonatomic,strong)UILabel *serviceContentL;
//截止时间
@property (nonatomic,strong)UILabel *stopTimeL;
//订单基本内容
@property (nonatomic,strong)UILabel *serviceInfoL;
//订单价格
@property (nonatomic,strong)UILabel *orderMoney;
//订单状态
@property (nonatomic,strong)UILabel *orderState;
//受护人地址
@property (nonatomic,strong)UILabel *addressL;
//受护人基本信息
@property (nonatomic,strong)UILabel *userInfoL;
//支付状态
@property (nonatomic,strong)UILabel *payStatusLabel;
//浏览订单详情
@property (nonatomic,strong)void(^showOrderDetailBlock)();
//查看受护人地址
@property (nonatomic,strong)void(^locationBlock)();
//查看受护人基本信息
@property (nonatomic,strong)void(^showUserInfoBlock)();
//取消订单
@property (nonatomic,strong)void(^cancleOrderBlock)();
//支付订单
@property (nonatomic,strong)void(^payMoneyBlock)();
//订单的基本信息
@property(strong,nonatomic)NSDictionary *orderInfoDict;

//0:预约框  1:已预约  2:进行中  3:已完成
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize orderType:(NSInteger)orderType;

@end
