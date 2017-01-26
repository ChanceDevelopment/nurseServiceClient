//
//  nurseServiceDefine.h
//  nurseService
//
//  Created by Tony on 16/7/29.
//  Copyright © 2016年 iMac. All rights reserved.
//

#ifndef nurseServiceDefine_h
#define nurseServiceDefine_h

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double ) 568 ) < DBL_EPSILON )
#define ALBUMNAME @"KunYuanDocument"
//#define ALBUMNAMEDOCUMENT @"FuYangDocument"
#define NAVTINTCOLOR [UIColor whiteColor]
#define ISIOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.9)
#define ISIOS6 ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.9)
#define IOS7OFFSET        64

//百度地图的key
#define BAIDUMAPKEY @"wahybut4ENzt0edEW9GWvxGGQU0z6dt5"


//自己服务器的通信模块
#define EASEMOBKEY @"godchance#aishangfuyang"
//parse
#define PARSEID @"0UMEqqvx8ykfdxtmlGjOmpEmALI6P3htEFG36wbl"
#define PARSEKEY @"eniHIEQDWZxmPlBRRF71105eoaioEGUotgUK2ryS"


#define QQKEY @"8VsUOu0ZTKHo2aEp"
#define SINAWEIBOKEY @"568898243"
#define TENCENTKEY @"8VsUOu0ZTKHo2aEp"
#define WECHATKEY @"wxd816a39ef2473856"

#define QQAPPSECRET @"566d0e00e0f55a9c1c00a604"
#define SINAWEIBOAPPSECRET @"38a4f8204cc784f81f9f0daaf31e02e3"
#define TENCENTAPPSECRET @"ae36f4ee3946e1cbb98d6965b0b2ff5c"
#define WECHATAPPSECRET @"b10cc06cca0a352950698f4b13d74ae4"

#define WECHATREDURECTURI @"http://www.sharesdk.cn"
#define QQREDURECTURI @"http://www.sharesdk.cn"
#define SINAWEIBOREDURECTURI @"http://www.sharesdk.cn"
#define TENCENTREDURECTURI @"http://www.sharesdk.cn"
#define WECHATREDURECTURI @"http://www.sharesdk.cn"

#define RONGCLOUDAPPSECRET @"3ziF82PRCob"
#define RONGCLOUDAPPKEY @"25wehl3uwoytw"
//激光推送的key
#define JPUSHAPPKEY @"8121db7759363542b25159b8"
//shareSDK的key
#define SHARESDKKEY @"1b0688dc89af4"
#define SHARESDKAPPSECRET @"d1af71ca484a3b7744eba120c941bb8b"

#define SHARESDKSMSKEY @"e85925a8eb1a"
#define SHARESDKSMSAPPSECRET @"d96120d4a619a057e3c6845529e213d9"
//友盟iPhone的key
#define UMANALYSISKEY @"587195a065b6d624cf001b68"
//友盟iPad的key
#define UMANALYSISKEY_HD @"587195a065b6d624cf001b68"


//成功获取当前城市
#define kGetCitySucceedNotification @"GetCitySucceedNotification"
//上次定位的城市
#define kPreLocationCityKey @"preLocationCityKey"

//添加被受保护人信息成功通知
#define kAddProtectedUserInfoNotification @"AddProtectedUserInfoNotification"
//获取分类数据成功
#define kLoadHospitalDataNotification @"loadHospitalDataSucceed"
#define kLoadMajorDataNotification @"loadMajorDataSucceed"

#define kLoadLeftMenuNotification @"loadLeftMenuSucceed"
//登录状态发生变化的通知
#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"

//更新个人信息
#define kUpdateUserInfoNotification @"updateUserInfoNotification"

#define UPDATEUSER_NOTIFICATION @"updateUser"

#define RECEIVEBUDDYINVITE_NOTIFICATION @"receiveBuddyInvite"

//图片上传成功发出的通知
#define UPLOADIMAGESUCCEED_NOTIFICATION @"uploadImageSucceed"

//支付账号
#define kPayAccount @"userCity"
//支付密码
#define kPayPassword @"userDistrict"
//支付余额
#define kPayBalance @"userBalance"

//更新订单信息
#define kUpdateOrderNotification @"updateOrderNotification"

//用户支付信息更新通知
#define kUpdateUserPayInfoNotificaiton @"updateUserPayInfoNotificaiton"
//用户的支付信息
#define kUserPayInfoKey @"userPayInfoKey"
//用户的签名 sign
#define USERSIGNKEY @"userSignKey"
//用户的ID userid
#define USERIDKEY @"userIDKey"
#define USERTOKENKEY @"userTokenKey"
//用户的资料
#define kUserDataKey @"userDataKey"
//用户详情资料
#define kUserDetailDataKey @"userDetailDataKey"
#define USERACCOUNTKEY @"userAccountKey"
//用户的登录账号
#define USERPASSWORDKEY @"userPasswordKey"
#define USERHAVELOGINKEY @"userHaveLogin"
#define FRIENDLISTDOWNLOADSUCCEED @"friendDownloadSucceed"

#define ERRORREQUESTTIP @"网络出错，请稍后再试!"
#define MODIFYPASSWORDKEY @"modifyPasswordKey"

#define RGB(r,g,b,a)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

//Link notificaiton点击label的某种链接的通知
#define LinkNOTIFICATION @"LinkNotification"
//Label的vaule的key
#define LINKVALUEKey @"linkValue"
//Label的Type的key
#define LINKTypeKey @"linkType"

#define TOPNAVIHEIGHT 44
//请求成功的状态码
#define REQUESTCODE_SUCCEED 200
//活动的图标空位符号
#define EMPTYSTRING @"     : "
//默认橙色的RGB
#define APPDEFAULTORANGE ([UIColor colorWithRed:175.0 / 255.0 green:88.0 / 255.0 blue:156.0 / 255.0 alpha:1.0])
//默认标题颜色
#define APPDEFAULTTITLECOLOR ([UIColor whiteColor])
//默认标题的字体
#define APPDEFAULTTITLETEXTFONT ([UIFont fontWithName:@"Helvetica" size:20.0])
//默认table的背景颜色
#define APPDEFAULTTABLEBACKGROUNDCOLOR ([UIColor colorWithWhite:245.0 / 255.0 alpha:1.0])
//默认table的分割线颜色
#define APPTABLESEPARATORCOLOR ([UIColor colorWithWhite:237.0 / 255.0 alpha:1.0])
//默认view的背景颜色
#define APPDEFAULTVIEWCOLOR ([UIColor whiteColor])
//图片加载出错的时候默认图
#define DEFAULTERRORIMAGE @"errorImage"

//当清理所有的推送标签的时候默认的标签
#define DEFAULTPUSHTAG @"xTdn8EVY3TeyCXrdkjaMdHOv"

#define kGetCancelOrderDataNotification @"kGetCancelOrderDataNotification"

#define kHanldeCancelOrderNotification @"kHanldeCancelOrderNotification"
//登录的广播
#define LOGINSTATEKEY @"loginStateKey"
#define LOGINOUTKEY   @"loginOut"       //退出登录
#define LOGINKEY   @"login"       //登录
#define UPDATEUSER @"updateUser"

//系统的设置
#define NEWSNOTIFY        @"newsNotify"         //消息通知
#define PLAYSOUND         @"playSound"          //声音
#define VIBRATION         @"vibration"          //震动
#define IOS7OFFSET        64
#define SHAREACTIVITYAUTO @"shareActivityAuto" //活动自动分享
#define ACTIVITYRECOMMEND @"activityRecommend" //活动推荐
#define FRIENDNEWSREMIND  @"friendNewsRemind"  //好友消息提醒
#define ACTIVITYREMIND    @"activityRemind"    //活动开始提醒
#define CIRCLEREPLY       @"circleReply"       //圈子回复
#define SYSTEMNOTIFY      @"systemNotify"      //系统通知
#define LOUDSPEAKER       @"loudSpeaker"       //扬声器

typedef enum {
    ENUM_SEX_Boy = 1,//男
    ENUM_SEX_Girl //女
} ENUM_SEXType;

typedef enum{
    eOrderStatusTypeReceive = 0,
    eOrderStatusTypeContact = 1,
    eOrderStatusTypeGo = 2,
    eOrderStatusTypeStart = 3,
    eOrderStatusTypeFinish = 4
} eOrderStatusType;

#endif /* nurseServiceDefine_h */
