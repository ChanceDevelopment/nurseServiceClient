//
//  Tool.m
//  iGangGan
//
//  Created by HeDongMing on 15/12/9.
//  Copyright © 2015年 iMac. All rights reserved.
//

#import "Tool.h"
#include <sys/xattr.h>
#import "HeSysbsModel.h"

@implementation Tool

+ (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

+ (CGSize)sizeWithString:(NSString *)str font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *dict = @{NSFontAttributeName : font};
    // 如果将来计算的文字的范围超出了指定的范围,返回的就是指定的范围
    // 如果将来计算的文字的范围小于指定的范围, 返回的就是真实的范围
    CGSize size =  [str boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    return size;
}

+ (NSString *)getDeviceUUid
{
//    return @"7c6e8381d8cdc0fa";
    NSString *libraryfolderPath = [NSHomeDirectory() stringByAppendingString:@"/Library"];
    NSString *myPath = [libraryfolderPath stringByAppendingPathComponent:ALBUMNAME];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:myPath]) {
        [fm createDirectoryAtPath:myPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *documentString = [myPath stringByAppendingPathComponent:@"UserData"];
    if(![fm fileExistsAtPath:documentString])
    {
        [fm createDirectoryAtPath:documentString withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *uuidPath = [documentString stringByAppendingPathComponent:@"uuid.plist"];
    NSDictionary *uuidDic = [[NSDictionary alloc] initWithContentsOfFile:uuidPath];
    NSString *uuid = [uuidDic objectForKey:@"uuid"];
    if (uuidDic && uuid) {
        
        return uuid;
    }
    Class cls = NSClassFromString(@"UMANUtil");
    SEL deviceIDSelector = @selector(openUDIDString);
    NSString *deviceID = nil;
    if(cls && [cls respondsToSelector:deviceIDSelector]){
        deviceID = [cls performSelector:deviceIDSelector];
    }
    uuidDic = [[NSDictionary alloc] initWithObjectsAndKeys:deviceID,@"uuid", nil];
    [uuidDic writeToFile:uuidPath atomically:YES];
    return deviceID;
}

+(NSString *)getVersion
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    return deviceString;
    
    NSArray *modelArray = @[
                            
                            @"i386", @"x86_64",
                            
                            @"iPhone1,1",
                            @"iPhone1,2",
                            @"iPhone2,1",
                            @"iPhone3,1",
                            @"iPhone3,2",
                            @"iPhone3,3",
                            @"iPhone4,1",
                            @"iPhone5,1",
                            @"iPhone5,2",
                            @"iPhone5,3",
                            @"iPhone5,4",
                            @"iPhone6,1",
                            @"iPhone6,2",
                            
                            @"iPod1,1",
                            @"iPod2,1",
                            @"iPod3,1",
                            @"iPod4,1",
                            @"iPod5,1",
                            
                            @"iPad1,1",
                            @"iPad2,1",
                            @"iPad2,2",
                            @"iPad2,3",
                            @"iPad2,4",
                            @"iPad3,1",
                            @"iPad3,2",
                            @"iPad3,3",
                            @"iPad3,4",
                            @"iPad3,5",
                            @"iPad3,6",
                            
                            @"iPad2,5",
                            @"iPad2,6",
                            @"iPad2,7",
                            ];
    NSArray *modelNameArray = @[
                                
                                @"iPhone Simulator", @"iPhone Simulator",
                                
                                @"iPhone 2G",
                                @"iPhone 3G",
                                @"iPhone 3GS",
                                @"iPhone 4(GSM)",
                                @"iPhone 4(GSM Rev A)",
                                @"iPhone 4(CDMA)",
                                @"iPhone 4S",
                                @"iPhone 5(GSM)",
                                @"iPhone 5(GSM+CDMA)",
                                @"iPhone 5c(GSM)",
                                @"iPhone 5c(Global)",
                                @"iphone 5s(GSM)",
                                @"iphone 5s(Global)",
                                
                                @"iPod Touch 1G",
                                @"iPod Touch 2G",
                                @"iPod Touch 3G",
                                @"iPod Touch 4G",
                                @"iPod Touch 5G",
                                
                                @"iPad",
                                @"iPad 2(WiFi)",
                                @"iPad 2(GSM)",
                                @"iPad 2(CDMA)",
                                @"iPad 2(WiFi + New Chip)",
                                @"iPad 3(WiFi)",
                                @"iPad 3(GSM+CDMA)",
                                @"iPad 3(GSM)",
                                @"iPad 4(WiFi)",
                                @"iPad 4(GSM)",
                                @"iPad 4(GSM+CDMA)",
                                
                                @"iPad mini (WiFi)",
                                @"iPad mini (GSM)",
                                @"ipad mini (GSM+CDMA)"
                                ];
    NSInteger modelIndex = - 1;
    NSString *modelNameString = nil;
    modelIndex = [modelArray indexOfObject:deviceString];
    if (modelIndex >= 0 && modelIndex < [modelNameArray count]) {
        modelNameString = [modelNameArray objectAtIndex:modelIndex];
    }
    
    
    NSLog(@"----设备类型---%@",modelNameString);
    return modelNameString;
}

+ (NSString *)getPlatformInfo
{
    return @"ios";
}

+ (NSString *)getCurrentTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}

+ (int)addFileSkipBackupAttribute: (NSString*) filePath
{
    NSURL* url = [NSURL fileURLWithPath:filePath];
    const char* fileSysPath = [[url path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    return setxattr(fileSysPath, attrName, &attrValue, sizeof(attrValue), 0, 0);
}

+ (NSData *)deleteErrorStringInData:(NSData *)inputData
{
    NSString *temp = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //留意20150918曾经删除
    //    temp = [temp stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    temp = [temp stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"&" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"•	" withString:@""];
    
    return [temp dataUsingEncoding:NSUTF8StringEncoding];
//    return temp;
}


+ (NSString *)replaceUnicode:(NSString *)unicodeStr{
    NSString *returnStr = [unicodeStr stringByReplacingOccurrencesOfString:@"\\\'" withString:@"'"];
    return returnStr;
    
}



+ (void)canceliClouldBackup
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:plistPath1] objectEnumerator];
    NSString* fileName;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [plistPath1 stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:fileAbsolutePath])
        {
            NSURL *myurl = [NSURL fileURLWithPath:fileAbsolutePath];
            [self addSkipBackupAttributeToItemAtURL:myurl];
        }
        NSURL *myurl = [NSURL fileURLWithPath:fileAbsolutePath];
        [self addSkipBackupAttributeToItemAtURL:myurl];
        
    }
    
    NSString *libraryfolderPath = [NSHomeDirectory() stringByAppendingString:@"/Library"];
    childFilesEnumerator = [[manager subpathsAtPath:libraryfolderPath] objectEnumerator];
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [libraryfolderPath stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:fileAbsolutePath])
        {
            NSURL *myurl = [NSURL fileURLWithPath:fileAbsolutePath];
            [self addSkipBackupAttributeToItemAtURL:myurl];
        }
    }
}

//IOS5或者以上的版本处理不备份都iCloud的方法
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

+ (NSString *) checkRegisterAccount:(NSString *)userNameVal
{
    NSString * regex_userName = @"^[a-zA-Z0-9_-]{6,18}$";//用户名
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex_userName];
    //----点击确定隐藏键盘
    if(![pred evaluateWithObject:userNameVal]){
        return @"请填写正确用户名(数字,字母,下划线)";
        //        [self.view makeToast:@"请填写正确用户名(数字,字母,下划线)" duration:2.0 position:@"center"];
    }else{
        return nil;
    }
}

+ (NSString *) checkRegisterPassword:(NSString *)userPwdVal
{
    NSString * regex_userPwd = @"[a-zA-Z0-9]{6,15}";//密码
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", userPwdVal];
    //----点击确定隐藏键盘
    pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex_userPwd];
    if(![pred evaluateWithObject:userPwdVal]){
        return @"请填写6-15位密码数字或字母";
    }else {
        return nil;
    }
}

+ (NSDictionary *)getUserDict
{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:USERACCOUNTKEY];
    if (username == nil) {
        username = @"";
    }
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:USERPASSWORDKEY];
    if (password == nil) {
        password = @"";
    }
    
    NSDictionary *userDict = @{USERACCOUNTKEY:username,USERPASSWORDKEY:password};
    return userDict;
}

/*
+ (void)initUserWithDict:(NSDictionary *)dict
{
    HeSysbsModel *sysModel = [HeSysbsModel getSysbsModel];
    User *user = [[User alloc] init];
    sysModel.user = user;
    
    NSString *username = [dict objectForKey:@"username"];
    if ([username isMemberOfClass:[NSNull class]] || username == nil) {
        username = @"";
    }
    user.username = username;
    
    NSString *nickname = [dict objectForKey:@"nickname"];
    if ([nickname isMemberOfClass:[NSNull class]] || nickname == nil) {
        nickname = @"";
    }
    user.nickname = nickname;
    
    NSString *industry = [dict objectForKey:@"industry"];
    if ([industry isMemberOfClass:[NSNull class]] || industry == nil) {
        industry = @"";
    }
    user.industry = industry;
    
    NSString *companyname = [dict objectForKey:@"companyname"];
    if ([companyname isMemberOfClass:[NSNull class]] || companyname == nil) {
        companyname = @"";
    }
    user.companyname = companyname;
    
    id sexStr = [dict objectForKey:@"sex"];
    if ([sexStr isMemberOfClass:[NSNull class]] || sexStr == nil) {
        sexStr = @"";
    }
    NSInteger sex = [sexStr integerValue];
    user.sex = sex;
    
    NSString *profession = [dict objectForKey:@"profession"];
    if ([profession isMemberOfClass:[NSNull class]] || profession == nil) {
        profession = @"";
    }
    user.profession = profession;
    
    
    id birthdayObj = [dict objectForKey:@"birthday"];
    if ([birthdayObj isMemberOfClass:[NSNull class]] || birthdayObj == nil) {
        NSTimeInterval  timeInterval = [[NSDate date] timeIntervalSince1970];
        birthdayObj = [NSString stringWithFormat:@"%.0f000",timeInterval];
    }
    long long timestamp = [birthdayObj longLongValue];
    NSString *birthday = [NSString stringWithFormat:@"%lld",timestamp];
    if ([birthday length] > 3) {
        //时间戳
        birthday = [birthday substringToIndex:[birthday length] - 3];
    }
    birthday = [Tool convertTimespToString:[birthday longLongValue]];
    if ([birthday isMemberOfClass:[NSNull class]] || birthday == nil) {
        birthday = @"";
    }
    user.birthday = birthday;
    
    NSString *idcard = [dict objectForKey:@"idcard"];
    if ([idcard isMemberOfClass:[NSNull class]] || idcard == nil) {
        idcard = @"";
    }
    user.idcard = idcard;
    
    NSString *workaddress = [dict objectForKey:@"workaddress"];
    if ([workaddress isMemberOfClass:[NSNull class]] || workaddress == nil) {
        workaddress = @"";
    }
    user.workaddress = workaddress;
    
    NSString *headurl = [dict objectForKey:@"headurl"];
    if ([headurl isMemberOfClass:[NSNull class]] || headurl == nil) {
        headurl = @"";
    }
    user.headurl = headurl;
    
    NSString *userID = [dict objectForKey:@"id"];
    if ([userID isMemberOfClass:[NSNull class]] || userID == nil) {
        userID = @"";
    }
    user.userID = userID;
    
    NSString *constellation = [dict objectForKey:@"constellation"];
    if ([constellation isMemberOfClass:[NSNull class]] || constellation == nil) {
        constellation = @"";
    }
    user.constellation = constellation;
    
    NSString *currentaddress = [dict objectForKey:@"currentaddress"];
    if ([currentaddress isMemberOfClass:[NSNull class]] || currentaddress == nil) {
        currentaddress = @"";
    }
    user.currentaddress = currentaddress;
    
    NSString *homeaddress = [dict objectForKey:@"homeaddress"];
    if ([homeaddress isMemberOfClass:[NSNull class]] || homeaddress == nil) {
        homeaddress = @"";
    }
    user.homeaddress = homeaddress;
    
    NSString *loginid = [dict objectForKey:@"loginid"];
    if ([loginid isMemberOfClass:[NSNull class]] || loginid == nil) {
        loginid = @"";
    }
    user.loginid = loginid;
    
    NSString *mail = [dict objectForKey:@"mail"];
    if ([mail isMemberOfClass:[NSNull class]] || mail == nil) {
        mail = @"";
    }
    user.mail = mail;
    
    NSString *name = [dict objectForKey:@"name"];
    if ([name isMemberOfClass:[NSNull class]] || name == nil) {
        name = @"";
    }
    user.name = name;
    
    NSString *phoneid = [dict objectForKey:@"phoneid"];
    if ([phoneid isMemberOfClass:[NSNull class]] || phoneid == nil) {
        phoneid = @"";
    }
    user.phoneid = phoneid;
    
    NSString *signature = [dict objectForKey:@"signature"];
    if ([signature isMemberOfClass:[NSNull class]] || signature == nil) {
        signature = @"";
    }
    user.signature = signature;
    
    id stateStr = [dict objectForKey:@"state"];
    if ([stateStr isMemberOfClass:[NSNull class]] || stateStr == nil) {
        stateStr = @"";
    }
    NSInteger state = [stateStr integerValue];
    user.state = state;
    
    NSString *phonenum = [dict objectForKey:@"phonenum"];
    if ([phonenum isMemberOfClass:[NSNull class]] || phonenum == nil) {
        phonenum = @"";
    }
    user.phonenum = phonenum;
    
    sysModel.user = user;
    
    [[HeFriendManager sharedInstance].userFriendInfoArray addObject:user];
    [[HeFriendManager sharedInstance].userMap setObject:user forKey:user.username];
}

*/

+ (int)getUpValueWithValue:(int)value1 otherValue:(int)value2
{
    int c1 = value1 / value2;
    if (value1 - c1 * value2 > 0) {
        c1++;
    }
    else if (c1 == 0){
        c1 = 1;
    }
    return c1;
}

+ (int)getColumnNumWithTotalNum:(NSInteger)totalCount
{
    int MAX_column = 4;
    int row = [Tool getUpValueWithValue:(int)totalCount otherValue:MAX_column];
    int column = 0;
    if (row < 1) {
        column = (int)totalCount % MAX_column;
    }
    else{
        column = MAX_column;
    }
    return column;
}

+ (int)getColumnNumWithTotalNum:(NSInteger)totalCount withMaxColumn:(NSInteger)maxcolumn
{
    //    int MAX_column = 4;
    int row = [Tool getUpValueWithValue:(int)totalCount otherValue:maxcolumn];
    int column = 0;
    if (row < 1) {
        column = (int)totalCount % maxcolumn;
    }
    else{
        column = maxcolumn;
    }
    return column;
}


+ (int)getRowNumWithTotalNum:(NSInteger)totalCount
{
    int MAX_column = 4;
    int MAX_row = 3;
    int row = [Tool getUpValueWithValue:(int)totalCount otherValue:MAX_column];
    if (row > MAX_row) {
        row = MAX_row;
    }
    return row;
}

+ (int)getRowNumWithTotalNum:(NSInteger)totalCount withMaxRow:(NSInteger)maxrow MaxColumn:(NSInteger)maxcolumn
{
    //    int MAX_column = 4;
    //    int MAX_row = 3;
    int row = [Tool getUpValueWithValue:(int)totalCount otherValue:maxcolumn];
    if (row > maxrow) {
        row = maxrow;
    }
    return row;
}


/*
+ (User *)getUserWithDict:(NSDictionary *)dict
{
    if (dict == nil) {
        return nil;
    }
    User *user = [[User alloc] init];
    
    NSString *username = [dict objectForKey:@"username"];
    if ([username isMemberOfClass:[NSNull class]] || username == nil) {
        username = @"";
    }
    user.username = username;
    
    NSString *nickname = [dict objectForKey:@"nickname"];
    if ([nickname isMemberOfClass:[NSNull class]] || nickname == nil) {
        nickname = @"";
    }
    user.nickname = nickname;
    
    NSString *industry = [dict objectForKey:@"industry"];
    if ([industry isMemberOfClass:[NSNull class]] || industry == nil) {
        industry = @"";
    }
    user.industry = industry;
    
    NSString *companyname = [dict objectForKey:@"companyname"];
    if ([companyname isMemberOfClass:[NSNull class]] || companyname == nil) {
        companyname = @"";
    }
    user.companyname = companyname;
    
    id sexStr = [dict objectForKey:@"sex"];
    if ([sexStr isMemberOfClass:[NSNull class]] || sexStr == nil) {
        sexStr = @"";
    }
    NSInteger sex = [sexStr integerValue];
    user.sex = sex;
    
    NSString *profession = [dict objectForKey:@"profession"];
    if ([profession isMemberOfClass:[NSNull class]] || profession == nil) {
        profession = @"";
    }
    user.profession = profession;
    
    
    id birthdayObj = [dict objectForKey:@"birthday"];
    if ([birthdayObj isMemberOfClass:[NSNull class]] || birthdayObj == nil) {
        NSTimeInterval  timeInterval = [[NSDate date] timeIntervalSince1970];
        birthdayObj = [NSString stringWithFormat:@"%.0f000",timeInterval];
    }
    long long timestamp = [birthdayObj longLongValue];
    NSString *birthday = [NSString stringWithFormat:@"%lld",timestamp];
    if ([birthday length] > 3) {
        //时间戳
        birthday = [birthday substringToIndex:[birthday length] - 3];
    }
    birthday = [Tool convertTimespToString:[birthday longLongValue]];
    if ([birthday isMemberOfClass:[NSNull class]] || birthday == nil) {
        birthday = @"";
    }
    user.birthday = birthday;
    
    NSString *idcard = [dict objectForKey:@"idcard"];
    if ([idcard isMemberOfClass:[NSNull class]] || idcard == nil) {
        idcard = @"";
    }
    user.idcard = idcard;
    
    NSString *workaddress = [dict objectForKey:@"workaddress"];
    if ([workaddress isMemberOfClass:[NSNull class]] || workaddress == nil) {
        workaddress = @"";
    }
    user.workaddress = workaddress;
    
    NSString *headurl = [dict objectForKey:@"headurl"];
    if ([headurl isMemberOfClass:[NSNull class]] || headurl == nil) {
        headurl = @"";
    }
    user.headurl = headurl;
    
    NSString *userID = [dict objectForKey:@"id"];
    if ([userID isMemberOfClass:[NSNull class]] || userID == nil) {
        userID = @"";
    }
    user.userID = userID;
    
    NSString *constellation = [dict objectForKey:@"constellation"];
    if ([constellation isMemberOfClass:[NSNull class]] || constellation == nil) {
        constellation = @"";
    }
    user.constellation = constellation;
    
    NSString *currentaddress = [dict objectForKey:@"currentaddress"];
    if ([currentaddress isMemberOfClass:[NSNull class]] || currentaddress == nil) {
        currentaddress = @"";
    }
    user.currentaddress = currentaddress;
    
    NSString *homeaddress = [dict objectForKey:@"homeaddress"];
    if ([homeaddress isMemberOfClass:[NSNull class]] || homeaddress == nil) {
        homeaddress = @"";
    }
    user.homeaddress = homeaddress;
    
    NSString *loginid = [dict objectForKey:@"loginid"];
    if ([loginid isMemberOfClass:[NSNull class]] || loginid == nil) {
        loginid = @"";
    }
    user.loginid = loginid;
    
    NSString *mail = [dict objectForKey:@"mail"];
    if ([mail isMemberOfClass:[NSNull class]] || mail == nil) {
        mail = @"";
    }
    user.mail = mail;
    
    NSString *name = [dict objectForKey:@"name"];
    if ([name isMemberOfClass:[NSNull class]] || name == nil) {
        name = @"";
    }
    user.name = name;
    
    NSString *phoneid = [dict objectForKey:@"phoneid"];
    if ([phoneid isMemberOfClass:[NSNull class]] || phoneid == nil) {
        phoneid = @"";
    }
    user.phoneid = phoneid;
    
    NSString *signature = [dict objectForKey:@"signature"];
    if ([signature isMemberOfClass:[NSNull class]] || signature == nil) {
        signature = @"";
    }
    user.signature = signature;
    
    id stateStr = [dict objectForKey:@"state"];
    if ([stateStr isMemberOfClass:[NSNull class]] || stateStr == nil) {
        stateStr = @"";
    }
    NSInteger state = [stateStr integerValue];
    user.state = state;
    
    NSString *phonenum = [dict objectForKey:@"phonenum"];
    if ([phonenum isMemberOfClass:[NSNull class]] || phonenum == nil) {
        phonenum = @"";
    }
    user.phonenum = phonenum;
    
    return user;
}
*/
 
+ (NSString *)getUserHeadImageURLWithiconAddress:(NSString *)iconAddress
{
    NSString *imageURL = iconAddress;
    return imageURL;
}

+ (NSString *)getUserDataPath
{
    NSString *libraryfolderPath = [NSHomeDirectory() stringByAppendingString:@"/Library"];
    NSString *myPath = [libraryfolderPath stringByAppendingPathComponent:ALBUMNAME];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:myPath]) {
        [fm createDirectoryAtPath:myPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *documentString = [myPath stringByAppendingPathComponent:@"UserData"];
    
    if(![fm fileExistsAtPath:documentString])
    {
        [fm createDirectoryAtPath:documentString withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return documentString;
}

+ (NSString *)getUn_UploadPath
{
    NSString *libraryfolderPath = [NSHomeDirectory() stringByAppendingString:@"/Library"];
    NSString *myPath = [libraryfolderPath stringByAppendingPathComponent:ALBUMNAME];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:myPath]) {
        [fm createDirectoryAtPath:myPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *documentString = [myPath stringByAppendingPathComponent:@"UnUploadImage"];
    
    if(![fm fileExistsAtPath:documentString])
    {
        [fm createDirectoryAtPath:documentString withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return documentString;
}

+ (NSString *)convertTimespToString:(long long)timesp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timesp];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

+ (long long)convertStringToTimesp:(NSString *)timeString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    
    NSDate* date = [formatter dateFromString:timeString];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    return [timeSp longLongValue];
}

+ (NSDate *)convertTimespToDate:(long long)timesp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSString *timeString = [NSString stringWithFormat:@"%lld",timesp];
    NSDate *date = [formatter dateFromString:timeString];
    return date;
}

+ (NSString *)convertTimespToString:(long long)timesp dateFormate:(NSString *)dateFormate
{
    if (dateFormate == nil) {
        dateFormate = @"MM-dd HH:mm";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:dateFormate];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timesp];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

+ (long long)convertStringToTimesp:(NSString *)timeString dateFormate:(NSString *)dateFormate
{
    if (dateFormate == nil) {
        dateFormate = @"MM-dd HH:mm";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:dateFormate];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    
    NSDate* date = [formatter dateFromString:timeString];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    return [timeSp longLongValue];
}

+ (NSDate *)convertTimespToDate:(long long)timesp dateFormate:(NSString *)dateFormate
{
    if (dateFormate == nil) {
        dateFormate = @"MM-dd HH:mm";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:dateFormate];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSString *timeString = [NSString stringWithFormat:@"%lld",timesp];
    NSDate *date = [formatter dateFromString:timeString];
    return date;
}

+ (NSDate *)convertTimesToDate:(NSString *)time dateFormate:(NSString *)dateFormate
{
    if (dateFormate == nil) {
        dateFormate = @"MM-dd HH:mm";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:dateFormate];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *date = [formatter dateFromString:time];
    return date;
}

+ (NSString *)getAppID
{
    return @"53cffe6288434205a46463e3a3448168";
}

+ (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    //    LEDEBUG(@"hexdata: %@", hexData);
    return hexData;
}

+ (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

+ (NSData *)stringToHexData:(NSString *)string
{
    NSInteger len = [string length] / 2;    // Target length
    unsigned char *buf = malloc(len);
    unsigned char *whole_byte = buf;
    char byte_chars[3] = {'\0','\0','\0'};
    
    int i;
    for (i=0; i < [string length] / 2; i++) {
        byte_chars[0] = [string characterAtIndex:i*2];
        byte_chars[1] = [string characterAtIndex:i*2+1];
        *whole_byte = strtol(byte_chars, NULL, 16);
        whole_byte++;
    }
    
    NSData *data = [NSData dataWithBytes:buf length:len];
    free( buf );
    return data;
}

+ (BOOL)isUserHaveLogin
{
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:USERACCOUNTKEY];
    if (account == nil || [account isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

+ (UIImage *) buttonImageFromColor:(UIColor *)color withImageSize:(CGSize)imageSize{
    CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


//获取app的版本号
+ (NSString *)getAppVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getAppBuildVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

//获取app的协议头
+ (NSString *)getAppScheme
{
    return [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
}

//获取系统的版本
+ (NSString *)getSysVersion
{
    return [[UIDevice currentDevice] systemName];
}

+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    if (mobileNum == nil || [mobileNum isEqualToString:@""]) {
        
        return NO;
    }
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (NSString *)compareCurrentTime:(NSString *)comparedateline
{
    long long int localdateline = [comparedateline longLongValue];
    NSDate *compareDate = [NSDate dateWithTimeIntervalSince1970:localdateline];
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
    
    timeInterval = -timeInterval;
    
    long temp = 0;
    
    NSString *result;
    
    if (timeInterval < 60) {
        
        result = [NSString stringWithFormat:@"今天"];
        
    }
    
    else if((temp = timeInterval/60) <60){
        
        result = [NSString stringWithFormat:@"今天"];
        
    }
    
    
    
    else if((temp = temp/60) <24){
        
        result = [NSString stringWithFormat:@"今天"];
        
    }
    
    else if((temp = temp/24) <30){
        if (temp == 1) {
            result = [NSString stringWithFormat:@"昨天"];
        }
        else if (temp == 2) {
            result = [NSString stringWithFormat:@"前天"];
        }
        else{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSTimeZone *timeZone = [NSTimeZone localTimeZone];
            
            [formatter setTimeZone:timeZone];
            
            [formatter setDateFormat : @"M-d"];
            result = [formatter stringFromDate:compareDate];
        }
        
    }
    
    else if((temp = temp/30) <12){
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        
        [formatter setTimeZone:timeZone];
        
        [formatter setDateFormat : @"M-d"];
        result = [formatter stringFromDate:compareDate];
        
    }
    
    else{
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        [formatter setTimeZone:timeZone];
        [formatter setDateFormat : @"yyyy-M-d"];
        result = [formatter stringFromDate:compareDate];
    }
    
    
    
    return  result;
    
}

@end
