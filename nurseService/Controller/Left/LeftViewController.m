//
//  LeftViewController.m
//  YCW
//
//  Created by apple on 15/12/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "LeftViewController.h"
#import "HomeTabbarController.h"
#import "XDMultTableView.h"

@interface LeftViewController ()<XDMultTableViewDatasource,XDMultTableViewDelegate>
{
    NSArray *sectionArr;
    NSArray *titleArr;
    NSArray *titleImageArr;
    NSInteger currentSection;
}
@property (nonatomic, strong) XDMultTableView *tableView;

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor purpleColor];
    

    _tableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width - 64);

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = @"我是多级列表";
    titleArr = @[@"陪诊陪护", @"母婴护理", @"静脉输液", @"伤口造口", @"管道护理", @"专业护工", @"健康管理", @"临终关怀"];
    titleImageArr = @[@"icon_escort",@"icon_nursing",@"icon_infusion",@"icon_wound",@"icon_conduit",@"icon_nursing_workers",@"icon_health",@"icon_care"];
    sectionArr = @[@[@"1"],@[@"1"],@[@"PICC",@"输液港",@"压疮护理"],@[@"1"],@[@"1"],@[@"1"],@[@"1"],@[@"1"]];
    _tableView = [[XDMultTableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width-150, self.view.frame.size.height - 64)];
    //默认打开
    currentSection = 2;
    _tableView.openSectionArray = [NSArray arrayWithObjects:@2, nil];
    _tableView.delegate = self;
    _tableView.datasource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.autoAdjustOpenAndClose = NO;
    [self.view addSubview:_tableView];

}

//设置状态栏
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - datasource
- (NSInteger)mTableView:(XDMultTableView *)mTableView numberOfRowsInSection:(NSInteger)section{
    return [sectionArr[section] count];
}

- (XDMultTableViewCell *)mTableView:(XDMultTableView *)mTableView
              cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [mTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    UIView *view = [[UIView alloc] initWithFrame:cell.bounds] ;
    view.layer.backgroundColor  = [UIColor purpleColor].CGColor;
    view.layer.masksToBounds    = YES;
    view.layer.borderWidth      = 0.1;
    view.layer.borderColor      = [UIColor lightGrayColor].CGColor;
    
    cell.backgroundView = view;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSLog(@"###%ld:%ld",indexPath.row,currentSection);
    cell.textLabel.text =[NSString stringWithFormat:@"%@",[sectionArr[currentSection] objectAtIndex:indexPath.row]];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(XDMultTableView *)mTableView{
    return sectionArr.count;
}

-(NSString *)mTableView:(XDMultTableView *)mTableView titleForHeaderInSection:(NSInteger)section{
    return titleArr[section];
}

-(NSString *)mTableView:(XDMultTableView *)mTableView titleImageForHeaderInSection:(NSInteger)section{
    return titleImageArr[section];
}

#pragma mark - delegate
- (CGFloat)mTableView:(XDMultTableView *)mTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)mTableView:(XDMultTableView *)mTableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}


- (void)mTableView:(XDMultTableView *)mTableView willOpenHeaderAtSection:(NSInteger)section{
    NSLog(@"即将展开:%ld",section);
    currentSection = section;
}


- (void)mTableView:(XDMultTableView *)mTableView willCloseHeaderAtSection:(NSInteger)section{
    NSLog(@"即将关闭");
}

- (void)mTableView:(XDMultTableView *)mTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击cell:%ld:%ld",currentSection,indexPath.row);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
