//
//  HeUserOrderCell.h
//  nurseService
//
//  Created by Tony on 2017/1/17.
//  Copyright © 2017年 iMac. All rights reserved.
//  用户订单列表视图模板

#import "HeBaseTableViewCell.h"

@interface HeUserOrderCell : HeBaseTableViewCell
//服务内容标签
@property (nonatomic,strong)UILabel *serviceContentL;
//服务时间标签
@property (nonatomic,strong)UILabel *stopTimeL;
//订单价格
@property (nonatomic,strong)UILabel *orderMoney;
//受护人地址
@property (nonatomic,strong)UILabel *addressL;
//受护人的基本信息
@property (nonatomic,strong)UILabel *userInfoL;
//订单的支付
@property (nonatomic,strong)UILabel *payStatusLabel;

//查看订单详情
@property (nonatomic,strong)void(^showOrderDetailBlock)();
//查看受护人的位置
@property (nonatomic,strong)void(^locationBlock)();
//查看受护人的信息
@property (nonatomic,strong)void(^showUserInfoBlock)();
//取消订单
@property (nonatomic,strong)void(^cancleOrderBlock)();
//对订单进行支付
@property (nonatomic,strong)void(^payMoneyBlock)();
//订单信息的字典
@property(strong,nonatomic)NSDictionary *orderInfoDict;

//orderState：0:预约框  1:已预约  2:进行中  3:已完成
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize orderType:(NSInteger)orderType orderState:(NSInteger)orderState;

@end
