//
//  WebViewController.m
//  Tuan
//
//  Created by 夏 华 on 12-7-6.
//  Copyright (c) 2012年 无锡恩梯梯数据有限公司. All rights reserved.
//
#import "TopNaviViewController.h"


@implementation TopNaviViewController
{
    NSInteger addStatusBarHeight;
}
@synthesize topNaviTitle;
@synthesize topNaviView_topClass;
@synthesize topNaviText;
@synthesize commonJson;

- (void)loadView
{
    [super loadView];
    // If you create your views manually, you MUST override this method and use it to create your views.
    // If you use Interface Builder to create your views, then you must NOT override this method.
}

- (void)viewDidLoad
{
    addStatusBarHeight = STATUSBAR_HEIGHT;
    //--ios7 or later  添加 bar
    if (iOS7) {
//        UILabel *addStatusBar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAINSCREEN_WIDTH, 20)];
//        addStatusBar.backgroundColor = [UIColor blackColor];
//        [self.view addSubview:addStatusBar];
    }else{
        UILabel *addStatusBar = [[UILabel alloc] initWithFrame:CGRectMake(0, -20, MAINSCREEN_WIDTH, 20)];
        addStatusBar.backgroundColor = TOPNAVIBGCOLOR;
        [self.view addSubview:addStatusBar];
    }
    [super viewDidLoad];
    
    //top
    topNaviView_topClass = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAINSCREEN_WIDTH, TOPNAVIHEIGHT + addStatusBarHeight)];
    [self.view addSubview:topNaviView_topClass];
    topNaviView_topClass.userInteractionEnabled = YES;//这样才可以点击
    topNaviView_topClass.backgroundColor = [self getTopNaviColor];
    //----返回----
    UIButton *goBack = [[UIButton alloc] initWithFrame:CGRectMake(10, 2+ addStatusBarHeight, 53.5, 40)];
    [topNaviView_topClass addSubview:goBack];
    [goBack setBackgroundImage:[UIImage imageNamed:@"gobackBtn"] forState:UIControlStateNormal];
    [goBack addTarget:self action:@selector(onClickBack) forControlEvents:UIControlEventTouchUpInside];
    
    //文字
    topNaviText = [[UILabel alloc] initWithFrame:CGRectMake(60, 0+ addStatusBarHeight, MAINSCREEN_WIDTH-120, TOPNAVIHEIGHT)];
    topNaviText.textAlignment = NSTextAlignmentCenter;
    topNaviText.text = [self getTitle]; //60, 0, 250, TOPNAVIHEIGHT
    topNaviText.font = [UIFont systemFontOfSize:18];
    topNaviText.textColor = [UIColor whiteColor];
    topNaviText.userInteractionEnabled = YES;//这样才可以点击
    topNaviText.backgroundColor = [UIColor clearColor];
    [topNaviView_topClass addSubview:topNaviText];
    
    //-----是否显示搜索框------
    if ([self isShowSearchView]) {
        [self addSearchView];
    }
    //-----是否显示完成按钮----
    if ([self isShowFinishButton]) {
        [self addFinishButton];
    }
    //-----是否显示更多按钮----
    if ([self isShowMoreButton]) {
        [self addMoreBtn];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //代理置空，否则会闪退
    if (iOS7) {
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (iOS7) {
        //开启iOS7的滑动返回效果
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            //只有在二级页面生效
            if ([self.navigationController.viewControllers count] >= 2) {
                self.navigationController.interactivePopGestureRecognizer.enabled = YES;
                self.navigationController.interactivePopGestureRecognizer.delegate = self;
            }
            else{
                self.navigationController.interactivePopGestureRecognizer.delegate = nil;
                self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            }
        }
    }
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //开启滑动手势
    if (iOS7) {
        if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
        else{
            navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
}

//-----修改标题
-(NSString*)getTitle{
    return @"";
}
//-----修改标题栏背景颜色
-(UIColor *)getTopNaviColor{
    return TOPNAVIBGCOLOR;
}
//修改标题
+(int)getStatusBarHeight{
    return addStatusBarHeight;
}
//------搜索按钮-----
-(BOOL)isShowSearchView{
    return NO;
}

- (void)makeKeyBoardVisible
{
//    KKAppDelegate *appDelegate = (KKAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate.window makeKeyAndVisible];
}

//添加搜索
-(void)addSearchView{
    //搜索
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(150, 7, 160, 30)];
    [topNaviView_topClass addSubview:searchView];
    searchView.userInteractionEnabled = YES;
    searchView.backgroundColor = [UIColor whiteColor];
    [searchView.layer setMasksToBounds:YES];
    [searchView.layer setCornerRadius:15.0];//设置矩形四个圆角半径
    UITapGestureRecognizer *singleTap1 =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toSearchView)];
    [searchView addGestureRecognizer:singleTap1];//添加点击事件
    //搜索图标
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
    [searchView addSubview:searchIcon];
    searchIcon.backgroundColor = [UIColor clearColor];
    searchIcon.image = [UIImage imageNamed:@"magnifying"];
    //索搜文字
    UILabel *searchText = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 140, 30)];
    [searchView addSubview:searchText];
    searchText.backgroundColor = [UIColor whiteColor];
    searchText.font = TEXTFONT;
    searchText.text = @"搜索店铺商品";
    searchText.textColor = [UIColor grayColor];
}
//---跳转到搜索
-(void) toSearchView{
    NSLog(@"do nothing here just for sonClass to rewrite");
}
//完成按钮
//------搜索,完成按钮-----
-(BOOL)isShowFinishButton{
    return NO;
}
//-----完成按钮标题
-(NSString*)getFinishBtnTitle{
    return @"完成";
}
//------添加搜索-----
-(void)addFinishButton{
    //搜索
    UIButton *finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAINSCREEN_WIDTH - 60, 5+ addStatusBarHeight, 60, 34)];
    [topNaviView_topClass addSubview:finishBtn];
    finishBtn.backgroundColor = [UIColor clearColor];
    finishBtn.titleLabel.textColor = [UIColor whiteColor];
    [finishBtn setTitle:[self getFinishBtnTitle] forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(clickFinish) forControlEvents:UIControlEventTouchUpInside];
}
//---跳转到搜索
-(void) clickFinish{
    NSLog(@"do nothing here just for sonClass to rewrite");
}

//---topbar-----多个按钮----多于1个-----
-(BOOL)isShowMoreButton{
    return NO;
}
-(NSString*)getMoreBtnTitles{
    return @"";//------|分割的多个按钮标题------
}
-(void)addMoreBtn{
    NSString *titles = [self getMoreBtnTitles];
    NSArray *titleArr = [titles componentsSeparatedByString:@"|"];
    NSInteger titleCount = titleArr.count;
    NSInteger btnWidth = 40;
    NSInteger gap = 15;
    if(titleCount > 0){
        NSInteger starLeft = MAINSCREEN_WIDTH - (btnWidth + gap) * titleCount + gap - 5;
        for (int i = 0; i < titleCount; i++) {
            UIButton *finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(starLeft+(btnWidth+gap)*i, 5+ addStatusBarHeight, btnWidth, 34)];//5 34
            [topNaviView_topClass addSubview:finishBtn];
            finishBtn.tag = i;
            finishBtn.backgroundColor = [UIColor clearColor];
            finishBtn.titleLabel.textColor = [UIColor whiteColor];
            [finishBtn setTitle:titleArr[i] forState:UIControlStateNormal];
            finishBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
            [finishBtn addTarget:self action:@selector(clickMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
            //----最后一个后不加--|--
            if (i != titleCount-1) {
                //                UIView *gapLine = [[UILabel alloc] initWithFrame:CGRectMake(finishBtn.frame.origin.x+finishBtn.frame.size.width + gap/ 2.0, (topNaviView_topClass.frame.size.height - 20)/2.0, 1, 20)];
                //                gapLine.backgroundColor = [UIColor whiteColor];
                //                [topNaviView_topClass addSubview:gapLine];
            }
        }
    }
}
//------需要被覆盖-----
-(void)clickMoreBtn:(UIButton *)btn
{
}

//-----点击返回
-(void)onClickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


//拨打电话
-(void)json_dialPhone:(NSString *)jsonString{
//    NSDictionary *dict = [jsonString objectFromJSONString];
//    NSString *telPhone = [dict objectForKey:@"phone"];
//    if ([telPhone isMemberOfClass:[NSNull class]] || telPhone == nil) {
//        telPhone = @"";
//    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"拨打电话:%@",telPhone] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
//    [alert addButtonWithTitle:@"拨打"];
//    [alert setTag:12];
//    [alert show];
    
}

@end
