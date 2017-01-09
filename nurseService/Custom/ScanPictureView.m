//
//  ScanPictureView.m
//  com.mant.iosClient
//
//  Created by 何 栋明 on 13-10-12.
//  Copyright (c) 2013年 何栋明. All rights reserved.
//

#import "ScanPictureView.h"
#import "VIPhotoView.h"

@interface ScanPictureView ()
@property (strong, nonatomic) NSArray *buttons;
@property (nonatomic) BOOL viewIsIn;
@property (strong,nonatomic)NSDictionary *merchantDic;

@end

@implementation ScanPictureView
@synthesize picMutableArray;
@synthesize deleteDelegate;
@synthesize merchantDic;
@synthesize backBarItem;
@synthesize pictureScrollView;
@synthesize pageController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        modifyScroll = NO;
    }
    return self;
}

-(id)initWithArray:(NSMutableArray*)array selectButtonIndex:(NSInteger)index;
{
    self = [super init];
    if (self) {
        picMutableArray = [[NSMutableArray alloc] initWithArray:array copyItems:NO];
        selectButtonIndex = index;
        
    }
    return self;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    viewCancel = YES;
    pictureScrollView.delegate = nil;
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    viewCancel = NO;
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBarHidden = YES;
    
    navigationBar = [[UINavigationBar alloc] init];
    CGFloat offset = IOS7OFFSET;
    if (ISIOS7) {
        [navigationBar setBarTintColor:[UIColor whiteColor]];
    }
    else{
        offset = offset - [UIApplication sharedApplication].statusBarFrame.size.height;
        [navigationBar setTintColor:APPDEFAULTORANGE];
//        [navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBarIOS7_white"] forBarMetrics:UIBarMetricsDefault];
    }
    navigationBar.backgroundColor = [UIColor orangeColor];
    navigationBar.frame = CGRectMake(0, -offset, [UIScreen mainScreen].bounds.size.width, offset);
    
//    UIButton *backBT = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backBT setBackgroundImage:[UIImage imageNamed:@"btn_backItem"] forState:UIControlStateNormal];
//    [backBT setBackgroundImage:[UIImage imageNamed:@"btn_backItemHL"] forState:UIControlStateHighlighted];
//    [backBT addTarget:self action:@selector(backTolastView:) forControlEvents:UIControlEventTouchUpInside];
//    backBT.tag = 1;
//    backBT.frame = CGRectMake(0, 0, 25, 25);
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] init];
    leftBarItem.tintColor = [UIColor whiteColor];
    leftBarItem.title = @"返回";
    [leftBarItem setAction:@selector(backTolastView:)];
//    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] init];
    rightButtonItem.target = self;
    rightButtonItem.action = @selector(deletePic:);
    rightButtonItem.title = @"删除";
    rightButtonItem.tintColor = [UIColor orangeColor];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.9) {
        rightButtonItem.tintColor = [UIColor whiteColor];
    }
    backBarItem = [[UINavigationItem alloc] init];
//    backBarItem.rightBarButtonItem = rightButtonItem;
//    backBarItem.leftBarButtonItem = leftBarItem;
//    backBarItem.hidesBackButton = NO;
//    backBarItem.leftItemsSupplementBackButton = YES;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    backBarItem.titleView = label;
    backBarItem.leftBarButtonItem = leftBarItem;
    backBarItem.rightBarButtonItem = rightButtonItem;
    
    label.text = [NSString stringWithFormat:@"%ld/%ld",selectButtonIndex,[picMutableArray count]];
    [label sizeToFit];
    
    [navigationBar pushNavigationItem:backBarItem animated:YES];
    
    
    self.title = [[NSString alloc] initWithFormat:@"%ld/%ld",selectButtonIndex,[picMutableArray count]];
    
    self.pageController = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height + 20, 320, 10)];
    pictureScrollView = [[UIScrollView alloc] init];
    UIScreen *mainScreen = [UIScreen mainScreen];
    pictureScrollView.frame = CGRectMake(0, 0, 320, mainScreen.bounds.size.height);
    pictureScrollView.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.view addSubview:pictureScrollView];
    [self setupPage:selectButtonIndex];
    [self.view addSubview:navigationBar];
    
}


-(void)backTolastView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)modifyScrollView
{
    pictureScrollView.contentOffset = CGPointMake(0, 0);
    pictureScrollView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
}

- (void) genieToRect: (CGRect)rect edge: (BCRectEdge) edge deleteView:(VIPhotoView*)deletePicture
{
    NSTimeInterval duration = 1.0f;
    
    CGRect endRect = CGRectInset(rect, 5.0, 5.0);
    
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        button.enabled = NO;
    }];
    
    deletePicture.userInteractionEnabled = NO;
    [deletePicture genieInTransitionWithDuration:duration destinationRect:endRect destinationEdge:edge completion:
         ^{
             [self removeSubViewFromScrollView];
             [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
                 button.enabled = YES;
                 
    }];}];
//    [self performSelector:@selector(removeSubViewFromScrollView) withObject:nil afterDelay:1.0f];
}

-(void)removeSubViewFromScrollView
{
    /****删除图片****/
    NSInteger currentPage = pageController.currentPage;
    NSArray *array = [pictureScrollView subviews];
    for (UIView *subView in array) {
        if ([subView isMemberOfClass:[VIPhotoView class]]) {
            [subView removeFromSuperview];
        }
    }
    [picMutableArray removeObjectAtIndex:currentPage];
    
    [deleteDelegate deleteImageAtIndex:(int)currentPage];
    if ([picMutableArray count] == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    /****删除图片之后如果还有图片就要刷新视图****/
    if (currentPage == [picMutableArray count]) {
        selectButtonIndex = (int)currentPage;
    }
    else{
        selectButtonIndex = (int)currentPage + 1;
    }
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    /********************************/
    
    /********************************/
    [UIView setAnimationTransition:UIViewAnimationTransitionNone
                           forView:navigationBar cache:YES];//切换效果
    [self setupPage:selectButtonIndex];
    self.title = [NSString stringWithFormat:@"%ld/%ld",selectButtonIndex,[picMutableArray count]];
    [UIView commitAnimations];//显示动画效果
}

-(void)deletePic:(id)sender
{
    UIBarButtonItem *barButton = (UIBarButtonItem*)sender;
    if ([barButton.title isEqualToString:@"返回"]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    /****删除图片****/
    NSInteger currentPage = pageController.currentPage;
    NSArray *array = [pictureScrollView subviews];
//    VIPhotoView *firstView = [array objectAtIndex:currentPage];
//    CGRect frame = firstView.frame;
    VIPhotoView *deleteView = [array objectAtIndex:currentPage];
//    deleteView.frame = frame;
    [self genieToRect:CGRectMake(SCREENWIDTH - 40, 0, 30, 30) edge:BCRectEdgeBottom deleteView:deleteView];
}

-(void)tapGes:(id)sender
{
    CGFloat offset = IOS7OFFSET;
    if (!ISIOS7) {
        offset = offset - [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    
    CGFloat y = navigationBar.frame.origin.y;
    
    if (y < 0) {
        //显示
        navigationBar.frame = CGRectMake(0, -offset, [UIScreen mainScreen].bounds.size.width, offset);
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, offset);
        } completion:^(BOOL finished) {
            
        }];
    }
    else{
        //隐藏
        navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, offset);
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            navigationBar.frame = CGRectMake(0, -offset, [UIScreen mainScreen].bounds.size.width, offset);
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void)changePage:(id)sender
{
    
}

- (void)changeTitle:(id)sender
{
    self.title = [NSString stringWithFormat:@"%ld/%ld",pageController.currentPage + 1,[picMutableArray count]];
    ((UILabel *)(backBarItem.titleView)).text = [NSString stringWithFormat:@"%ld/%ld",pageController.currentPage + 1,[picMutableArray count]];
    [((UILabel *)(backBarItem.titleView)) sizeToFit];
    backBarItem.title = [NSString stringWithFormat:@"%ld/%ld",pageController.currentPage + 1,[picMutableArray count]];
}

-(void)setupPage:(NSInteger)page
{
    pictureScrollView.delegate = self;
    pictureScrollView.minimumZoomScale = 0.1;
    pictureScrollView.maximumZoomScale = 3.0;
    [pictureScrollView setBackgroundColor:[UIColor blackColor]];
    [pictureScrollView setCanCancelContentTouches:NO];
    pictureScrollView.clipsToBounds = YES;
    pictureScrollView.scrollEnabled = YES;
    pictureScrollView.pagingEnabled = YES;
    pictureScrollView.directionalLockEnabled = NO;
    pictureScrollView.alwaysBounceHorizontal = NO;
    pictureScrollView.alwaysBounceVertical = NO;
    pictureScrollView.showsHorizontalScrollIndicator = NO;
    pictureScrollView.showsVerticalScrollIndicator = NO;
    
    NSInteger nimages = 0;
    CGFloat cx = 0;
    
    for (int i = 0; i< [picMutableArray count]; i++) {
        AsynImageView *imageview = [picMutableArray objectAtIndex:i];
        NSString *bigImageurl = imageview.bigImageURL;
        if (bigImageurl == nil) {
            //本地上传的图片
            UIImage *image = imageview.image;
            
            CGRect rect = pictureScrollView.frame;
            rect.size.height = pictureScrollView.frame.size.height;
            rect.size.width = pictureScrollView.frame.size.width;
            rect.origin.x = cx;
            rect.origin.y = 0;
            
            VIPhotoView *zoomScrollView = [[VIPhotoView alloc] initWithFrame:rect andImage:image];
            zoomScrollView.autoresizingMask = (1 << 6) -1;
            zoomScrollView.showsHorizontalScrollIndicator = NO;
            zoomScrollView.userInteractionEnabled = NO;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            [zoomScrollView setUserInteractionEnabled:YES];
            [zoomScrollView addGestureRecognizer:tap];
            zoomScrollView.layer.backgroundColor = [[UIColor clearColor] CGColor];
            [pictureScrollView addSubview:zoomScrollView];
        }
        else{
            //网络图片
            CGRect rect = pictureScrollView.frame;
            rect.size.height = pictureScrollView.frame.size.height;
            rect.size.width = pictureScrollView.frame.size.width;
            rect.origin.x = cx;
            rect.origin.y = 0;
            
            VIPhotoView *zoomScrollView = [[VIPhotoView alloc] initWithFrame:rect imageURL:bigImageurl];
            zoomScrollView.autoresizingMask = (1 << 6) -1;
            zoomScrollView.showsHorizontalScrollIndicator = NO;
            zoomScrollView.userInteractionEnabled = NO;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            [zoomScrollView setUserInteractionEnabled:YES];
            [zoomScrollView addGestureRecognizer:tap];
            zoomScrollView.layer.backgroundColor = [[UIColor clearColor] CGColor];
            [pictureScrollView addSubview:zoomScrollView];
            
        }
        cx += pictureScrollView.frame.size.width;
        nimages++;
    }
    [pageController addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    pageController.numberOfPages = nimages;
    pageController.currentPage = page - 1;
    pageController.tag  = 0;
    [pictureScrollView setContentSize:CGSizeMake(cx, ([pictureScrollView frame].size.height))];
    CGRect frame = pictureScrollView.frame;
    frame.origin.x = page*SCREENWIDTH;
    frame.origin.y = 0;
    [self performSelector:@selector(changePage) withObject:nil afterDelay:0.3];
}

- (void)changePage
{
    CGRect frame = pictureScrollView.frame;
    frame.origin.x = (selectButtonIndex - 1)*SCREENWIDTH;
    frame.origin.y = 0;
    [pictureScrollView scrollRectToVisible:frame animated:YES];
    [self changeTitle:nil];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView1
{
    if (viewCancel) {
        return;
    }
    if (pageControlISChangingPage) {
        return;
    }
    CGFloat pageWidth = scrollView1.frame.size.width;
    int page = floor((scrollView1.contentOffset.x - pageWidth/2) / pageWidth) +1;
    pageController.currentPage = page;
    [self performSelector:@selector(changeTitle:) withObject:nil afterDelay:0.3];
    if (!modifyScroll) {
        modifyScroll = YES;
        [self modifyScrollView];
    }
}


-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    pageControlISChangingPage = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
