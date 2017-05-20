//
//  HeCommentNurseVC.m
//  nurseService
//
//  Created by Tony on 2017/1/16.
//  Copyright © 2017年 iMac. All rights reserved.
//  评论视图控制器

#import "HeCommentNurseVC.h"
#import "IQTextView.h"
#import "SAMTextView.h"

@interface HeCommentNurseVC ()
//输入框
@property(strong,nonatomic)IBOutlet SAMTextView *textView;
//护士头像
@property(strong,nonatomic)IBOutlet UIImageView *nurseImage;
//护士基本信息
@property(strong,nonatomic)IBOutlet UILabel *nurseLabel;
//评论等级的视图
@property(strong,nonatomic)IBOutlet UIView *markView;

@end

@implementation HeCommentNurseVC
{
    //当前的评论等级
    NSInteger currentRank;
}
@synthesize nurseDict;
@synthesize textView;
@synthesize nurseImage;
@synthesize nurseLabel;
@synthesize markView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = APPDEFAULTTITLETEXTFONT;
        label.textColor = APPDEFAULTTITLECOLOR;
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        label.text = @"评价";
        [label sizeToFit];
        self.title = @"评价";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

//初始化资源
- (void)initializaiton
{
    [super initializaiton];
}

//初始化各个视图
- (void)initView
{
    [super initView];
    textView.placeholder = @"写下您对护士的而评价";
    nurseImage.layer.masksToBounds = YES;
    nurseImage.layer.cornerRadius = 30;
    
    NSString *nurseHeader = nurseDict[@"nurseHeader"];
    if ([nurseHeader isMemberOfClass:[NSNull class]] || nurseHeader == nil) {
        nurseHeader = @"";
    }
    nurseHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,nurseHeader];
    [nurseImage sd_setImageWithURL:[NSURL URLWithString:nurseHeader] placeholderImage:[UIImage imageNamed:@"defalut_icon"]];
    
    NSString *nurseNick = nurseDict[@"nurseNick"];
    if ([nurseNick isMemberOfClass:[NSNull class]]) {
        nurseNick = @"";
    }
    nurseLabel.text = nurseNick;
    
    currentRank = 1;
    CGFloat imageDistance = 5;
    CGFloat imageH = 30;
    CGFloat imageW = 30;
    CGFloat imageY = 2.5;
    CGFloat imageX = (SCREENWIDTH - 20 - (5 * imageW) - (4 * imageDistance)) / 2.0;
    for (NSInteger index = 0; index < 5; index++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
        [button setBackgroundImage:[UIImage imageNamed:@"icon_collection"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"icon_collection_full"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(updateStart:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = index + 1;
        if (index < currentRank) {
            button.selected = YES;
        }
        imageX = imageX + imageW + imageDistance;
        [markView addSubview:button];
    }
}

//更新评论等级
- (void)updateStart:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        currentRank = button.tag;
    }
    else{
        currentRank = button.tag - 1;
    }
    if (currentRank < 0) {
        currentRank = 0;
    }
    NSArray *subViewArray = markView.subviews;
    for (NSInteger index = 0; index < [subViewArray count]; index++) {
        UIButton *button = subViewArray[index];
        if (index < currentRank) {
            button.selected = YES;
        }
        else{
            button.selected = NO;
        }
    }
}

//评价事件
- (IBAction)commitButtonClick:(id)sender
{
    if ([textView isFirstResponder]) {
        [textView resignFirstResponder];
    }
    NSString *content = textView.text;
    if ([content length] < 5) {
        [self showHint:@"请至少输入五个字"];
        return;
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *nurseId = nurseDict[@"nurseId"];
    if ([nurseId isMemberOfClass:[NSNull class]] || nurseId == nil) {
        nurseId = @"";
    }
    NSString *sendId = nurseDict[@"orderSendId"];
    if ([sendId isMemberOfClass:[NSNull class]] || sendId == nil) {
        sendId = @"";
    }
    
    
    NSString *mark = [NSString stringWithFormat:@"%ld",currentRank];
    //评价接口的请求参数
    NSDictionary * params  = @{@"userId":userId,@"nurseId":nurseId,@"sendId":sendId,@"content":content,@"mark":mark};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/evaluate/addevaluate.action",BASEURL];
    [self showHudInView:self.view hint:@"评价中..."];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[respondDict valueForKey:@"errorCode"] integerValue] == REQUESTCODE_SUCCEED){
            
            [self showHint:@"评价成功"];
            //评价成功，发出通知，通知各个界面进行页面更新
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateOrderDetailNotification" object:nil];
            [self performSelector:@selector(backToLastView) withObject:nil afterDelay:0.8];
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError* err){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
        NSLog(@"errorInfo = %@",err);
    }];
}

- (void)backToLastView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
