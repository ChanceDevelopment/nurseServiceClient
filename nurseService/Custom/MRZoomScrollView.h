//
//  MRZoomScrollView.h
//  ScrollViewWithZoom
//
//  Created by xuym on 13-3-27.
//  Copyright (c) 2013年 xuym. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsynImageView.h"


@interface MRZoomScrollView : UIScrollView <UIScrollViewDelegate>
{
    AsynImageView *imageView;
    UIImageView *myimageview;
    int flag;
}

- (id)initWithAsyImageFrame:(CGRect)frame;
- (id)initWithMyFrame:(CGRect)frame;
- (id)initWithImageFrame:(CGRect)frame;

@property (nonatomic, retain) AsynImageView *imageView;
@property (nonatomic, retain) UIImageView *myimageview;


@end
