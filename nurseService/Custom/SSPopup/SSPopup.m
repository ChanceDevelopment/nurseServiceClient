//
//  OrdersDropdownSelection.m
//  CooperChimney
//
//  Created by Karthik Baskaran on 29/09/16.
//  Copyright © 2016 Karthik Baskaran. All rights reserved.
//

#import "SSPopup.h"
#import "HeSubServiceCell.h"

@interface SSPopup ()
{
    AppDelegate *appDelegate;
    
    NSArray *ordersarray;
    
    UIButton *ParentBtn;
}
@end
@implementation SSPopup
@synthesize selectArray;

- (id)initWithFrame:(CGRect)frame delegate:(id<SSPopupDelegate>)delegate
{
    self = [super init];
    if ((self = [super initWithFrame:frame]))
    {
        self.SSPopupDelegate = delegate;
    }
    
    return self;
}


-(void)CreateTableview:(NSArray *)Contentarray withSender:(id)sender  withTitle:(NSString *)title setCompletionBlock:(VSActionBlock )aCompletionBlock{
    
    
    [self addTarget:self action:@selector(CloseAnimation) forControlEvents:UIControlEventTouchUpInside];
    
    self.alpha=0;
    self.backgroundColor=[UIColor colorWithWhite:0.00 alpha:0.5];
    completionBlock=aCompletionBlock;
    ParentBtn=(UIButton *)sender;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Title=title;

    
   DropdownTable=[[UITableView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-(self.frame.size.width/1.2)/2,self.frame.size.height/2-(self.frame.size.height/3)/2,self.frame.size.width/1.2,self.frame.size.height/3)];
    DropdownTable.backgroundColor=[UIColor whiteColor];
    DropdownTable.dataSource=self;
    DropdownTable.showsVerticalScrollIndicator=NO;
    DropdownTable.delegate=self;
    DropdownTable.layer.cornerRadius=5.0f;
    DropdownTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    
    [self addSubview:DropdownTable];

    
    ordersarray=[[NSArray alloc]initWithArray:Contentarray];
    
    
    NormalAnimation(self.superview, 0.30f,UIViewAnimationOptionTransitionNone,
                    
                    self.alpha=1;
               
)completion:nil];
    
}

- (void)commitButtonClick:(UIButton *)button
{
    NSLog(@"commitButtonClick");
    NSInteger section = 0;
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger row = 0; row < [ordersarray count]; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        HeSubServiceCell *cell = [DropdownTable cellForRowAtIndexPath:indexPath];
        if (cell.serviceButton.selected) {
            NSString *string = ordersarray[row];
            [array addObject: string];
        }
    }
    if ([array count] == 0) {
        [[UIApplication sharedApplication].keyWindow.rootViewController showHint:@"请选择套餐"];
        return;
    }
    selectArray = [[NSMutableArray alloc] initWithArray:array];
    [self.SSPopupDelegate selectWithArray:selectArray];
    
    [self CloseAnimation];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return tableView.frame.size.height/4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return tableView.frame.size.height/4;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/1.2, tableView.frame.size.height/4)];
    UIButton *commitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/1.2, tableView.frame.size.height/4)];
    [commitButton setTitle:@"确定" forState:UIControlStateNormal];
    [commitButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:commitButton.frame.size] forState:UIControlStateNormal];
    [commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitButton addTarget:self action:@selector(commitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:commitButton];
    return footerView;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *myview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,10)];
[myview setBackgroundColor:APPDEFAULTORANGE];
    
    
    UILabel *headLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, myview.frame.size.width, tableView.frame.size.height/4)];
    headLbl.backgroundColor=[UIColor clearColor];
    headLbl.textColor=[UIColor whiteColor];
    headLbl.text=Title?Title:@"Select";
    headLbl.textAlignment=NSTextAlignmentCenter;
    headLbl.font=AvenirMedium(18);
    [myview addSubview:headLbl];
    
    
    return myview;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.frame.size.height/4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [ordersarray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    CGSize cellsize = [tableView rectForRowAtIndexPath:indexPath].size;
    static NSString *cellIdentifier = @"HeSubServiceCell";
    
    HeSubServiceCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil)
        cell = [[HeSubServiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier cellSize:cellsize];
    cell.backgroundColor=[UIColor whiteColor];
    
    
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;

    NSString *menu = ordersarray[row];
    cell.serviceNameLabel.text = menu;
    for (NSString *temp in selectArray) {
        if ([temp isEqualToString:menu]) {
            cell.serviceButton.selected = YES;
            break;
        }
        else{
            cell.serviceButton.selected = NO;
        }
    }
    
//    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    
//    UILabel *Contentlbl =[[UILabel alloc]initWithFrame:CGRectMake(10,0,tableView.frame.size.width-20,tableView.frame.size.height/4)];
//    Contentlbl.backgroundColor=[UIColor clearColor];
//    Contentlbl.text=[ordersarray objectAtIndex:indexPath.row];
//    Contentlbl.textColor=[UIColor blackColor];
//    Contentlbl.textAlignment=NSTextAlignmentLeft;
//    Contentlbl.font=AvenirMedium(16);
//    [cell.contentView addSubview:Contentlbl];
//
//    
//    UIView *lineView =[[UIView alloc]initWithFrame:CGRectMake(0, Contentlbl.frame.origin.y+Contentlbl.frame.size.height-2,self.frame.size.width, 1.2)];
//    lineView.backgroundColor=[UIColor groupTableViewBackgroundColor];
//    [Contentlbl addSubview:lineView];
    
//    if(indexPath.row == [ordersarray count] -1){
//        
//        lineView.hidden=YES;
//    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HeSubServiceCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.serviceButton.selected = !cell.serviceButton.selected;
    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    
//    cell.contentView.backgroundColor=RGB(248, 218, 218);
//    
//
//    [ParentBtn setTitle:[ordersarray objectAtIndex:indexPath.row] forState:UIControlStateNormal]; //Setting title for Button
//
//
//    if (completionBlock) {
//        
//         completionBlock((int)indexPath.row);
//    }
//    
//    if ([self.SSPopupDelegate respondsToSelector:@selector(GetSelectedOutlet:)]) {
//        
//         [self.SSPopupDelegate GetSelectedOutlet:(int)indexPath.row];
//    }
    
    

}

-(void)CloseAnimation{
    
    NormalAnimation(self.superview, 0.30f,UIViewAnimationOptionTransitionNone,
                    
                    DropdownTable.alpha=0;
                    
                    
                    
                    )
completion:^(BOOL finished){
    
    [DropdownTable removeFromSuperview];
    [self removeFromSuperview];
    
    
}];
}

@end
