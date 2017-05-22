//
//  HeInstructionView.h
//  com.mant.iosClient
//
//  Created by 何 栋明 on 13-11-13.
//  Copyright (c) 2013年 何栋明. All rights reserved.
//  引导页视图控制器

#import <UIKit/UIKit.h>
#import "UIButton+Bootstrap.h"
#import "HeBaseViewController.h"

@interface HeInstructionView : HeBaseViewController<UIScrollViewDelegate>
{
    UIScrollView *myscrollView;
    UIPageControl *pageControl;
    BOOL pageControlIsChangingPage;
    NSMutableArray *images;
    UILabel *activityLabel;
    UIButton *enterButton;
    
}
@property(assign,nonatomic)int loadSucceedFlag;
@property(assign,nonatomic)BOOL hideEnterButton;

@end
