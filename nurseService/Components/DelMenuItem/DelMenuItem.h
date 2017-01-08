//
//  DelMenuItem.h
//  单耳兔
//
//  Created by yang on 15/9/22.
//  Copyright (c) 2015年 珠海单耳兔电子商务有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MenuItemDelegate;
@interface DelMenuItem : UIView{
    UIImage *delImage;
    NSString *delImageUrl;
    UIButton *removeButton;
    id <MenuItemDelegate> delegate;
}
@property (nonatomic,assign) NSInteger tag;
@property BOOL isInEditingMode;
@property BOOL isRemovable;
@property (nonatomic,strong) id <MenuItemDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *items;

+ (id)initWithImage:(UIImage *)image imageurl:(NSString *)imageUrl movable:(BOOL)removable;
- (void) updateTag:(int) newTag;
- (void) disableEditing;;
- (void) enableEditing;

@end

@protocol MenuItemDelegate <NSObject>
@optional
- (void)removeFromSpringboard:(int)index;
- (void)launch:(int)index;
@end
