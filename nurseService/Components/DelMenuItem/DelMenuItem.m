//
//  DelMenuItem.m
//  单耳兔
//
//  Created by yang on 15/9/22.
//  Copyright (c) 2015年 珠海单耳兔电子商务有限公司. All rights reserved.
//

#import "DelMenuItem.h"
#import "AsynImageView.h"

@implementation DelMenuItem
@synthesize tag,isInEditingMode,isRemovable,delegate,items;

- (id)initWithImage:(UIImage *)image imageurl:(NSString *)imageUrl movable:(BOOL)removable{
    self = [super initWithFrame:CGRectMake(0, 0, 100, 100)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        delImage             = image;
        delImageUrl          = imageUrl;
        self.isInEditingMode = NO;
        self.isRemovable     = removable;
    }
    return self;
}

+ (id)initWithImage:(UIImage *)image imageurl:(NSString *)imageUrl movable:(BOOL)removable{

    DelMenuItem *tempInstance = [[DelMenuItem alloc] initWithImage:image imageurl:imageUrl movable:removable];
    return tempInstance;
}

- (void) updateTag:(NSInteger)newTag{
    self.tag = newTag;
    removeButton.tag = newTag;
}

- (void) disableEditing{
    [[self layer] removeAllAnimations];
    [removeButton setHidden:YES];
    self.isInEditingMode = NO;
}

//开启编辑模式
- (void) enableEditing{
    if (self.isInEditingMode == YES)
        return;
    
    // put item in editing mode
    self.isInEditingMode = YES;
    
    // make the remove button visible
    [removeButton setHidden:NO];
    
    // start the wiggling animation
    CATransform3D transform;
    
    transform = CATransform3DMakeRotation(-0.08, 0, 0, 1.0);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:transform];
    animation.autoreverses = YES;
    animation.duration = 0.1;
    animation.repeatCount = 10000;
    animation.delegate = self;
    [[self layer] addAnimation:animation forKey:@"wiggleAnimation"];
}

# pragma mark - Drawing
- (void)drawRect:(CGRect)rect {
    // Drawing code
    AsynImageView *goodImage = [[AsynImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 80, 80)];
    goodImage.placeholderImage = [UIImage imageNamed:@"noData2"];
    goodImage.backgroundColor = [UIColor colorWithRed: 236/255.0 green:236/255.0 blue:236/255.0 alpha:1.0];
    goodImage.layer.masksToBounds = YES;
    goodImage.layer.borderWidth = 0;
    goodImage.layer.borderColor = [UIColor clearColor].CGColor;
    goodImage.contentMode = UIViewContentModeScaleAspectFill;
    if (delImage) {
        goodImage.image = delImage;
    }else if (![delImageUrl isEqualToString:@""]){
        goodImage.imageURL = delImageUrl;
    }
    [self addSubview:goodImage];
    
//    UIImage* img = delImage;
//    [img drawInRect:CGRectMake(10.0, 10.0, 80, 80)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 100, 100)];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = tag;
    [self addSubview:button];
    
    if (self.isRemovable) {
        // place a remove button on top right corner for removing item from the board
        removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [removeButton setFrame:CGRectMake(80, 0, 20, 20)];
        [removeButton setImage:[UIImage imageNamed:@"cancle.png"] forState:UIControlStateNormal];
        removeButton.backgroundColor = [UIColor clearColor];
        [removeButton addTarget:self action:@selector(removeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        removeButton.tag = tag;
        [removeButton setHidden:YES];
        [self addSubview:removeButton];
    }
}

- (void) clickItem:(id) sender {
    UIButton *theButton = (UIButton *) sender;
    [[self delegate] launch:theButton.tag];
}

- (void)removeButtonClicked:(id) sender  {
    [[self delegate] removeFromSpringboard:tag];
}

@end
