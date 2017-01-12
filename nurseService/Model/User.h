//
//  User.h
//  iGangGan
//
//  Created by HeDongMing on 15/12/14.
//  Copyright © 2015年 iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsynImageView.h"

@interface User : NSObject

@property(strong,nonatomic)NSString *couponCount; //用户名
@property(strong,nonatomic)NSString *userAddress;  //用户密码
@property(strong,nonatomic)NSString *userAge; //昵称
@property(strong,nonatomic)NSString *userBalance; //真实姓名
@property(strong,nonatomic)NSString *userCard; //判断是否单独的手机用户
@property(strong,nonatomic)NSString *userCardpic;
@property(strong,nonatomic)NSString *userCity;
@property(strong,nonatomic)NSString *userCommunicate;  //用户充当的角色

@property(strong,nonatomic)NSString *userCreatetime;  //用户的token，身份的唯一凭证
@property(strong,nonatomic)NSString *userDistrict;  //用户的头像
@property(strong,nonatomic)NSString *userEmail;  //用户的ID
@property(strong,nonatomic)NSString *userHeader;//生日


@property(strong,nonatomic)NSString *userId;
@property(strong,nonatomic)NSString *userIdenstate;
@property(strong,nonatomic)NSString *userInvitationcode;

@property(strong,nonatomic)NSString *userMark;
@property(strong,nonatomic)NSString *userName;
@property(strong,nonatomic)NSString *userNick;
@property(strong,nonatomic)NSString *userNote;

@property(strong,nonatomic)NSString *userPhone;
@property(strong,nonatomic)NSString *userPositionX;
@property(strong,nonatomic)NSString *userPositionY;
@property(strong,nonatomic)NSString *userProvince;
@property(strong,nonatomic)NSString *userPwd;
@property(strong,nonatomic)NSString *userSex;
@property(strong,nonatomic)NSString *userTruename;
@property(strong,nonatomic)NSString *userUsestate;

- (User *)initUserWithDict:(NSDictionary *)dict;
- (User *)initUserWithUser:(User *)user;

@end
