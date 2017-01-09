//
//  ScanPictureView.h
//  com.mant.iosClient
//
//  Created by 何 栋明 on 13-10-12.
//  Copyright (c) 2013年 何栋明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsynImageView.h"
#import "DeleteImageProtocol.h"
#import "UIView+Genie.h"
#import "MRZoomScrollView.h"
#import "HeBaseViewController.h"

@interface ScanPictureView : HeBaseViewController<UIScrollViewDelegate>
{
    
    BOOL viewCancel;
    BOOL pageControlISChangingPage;
    UINavigationBar *navigationBar;
    
    NSInteger selectButtonIndex;
    BOOL isback;
    BOOL modifyScroll;
}

-(id)initWithArray:(NSMutableArray*)array selectButtonIndex:(NSInteger)index;

@property(nonatomic,strong) NSMutableArray *picMutableArray;
@property(nonatomic,retain) id<DeleteImageProtocol>deleteDelegate;
@property(nonatomic,strong) UINavigationItem *backBarItem;
@property(nonatomic,strong) UIScrollView *pictureScrollView;
@property(nonatomic,strong) UIPageControl *pageController;

@end
