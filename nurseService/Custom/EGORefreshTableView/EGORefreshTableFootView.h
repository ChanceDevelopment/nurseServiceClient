//
//  EGORefreshTableFootView.h
//  TableViewPull
//
//  Created by 何 栋明 on 13-9-18.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	EGOOPullRefreshPulling1 = 0,
	EGOOPullRefreshNormal1,
	EGOOPullRefreshLoading1,
} EGOPullRefreshState1;

@protocol EGORefreshTableFootDelegate;
@interface EGORefreshTableFootView : UIView
{
        id _delegate;
        EGOPullRefreshState1 _state;
        
        UILabel *_lastUpdatedLabel;
        UILabel *_statusLabel;
        CALayer *_arrowImage;
        UIActivityIndicatorView *_activityView;
}

@property(nonatomic,assign) id <EGORefreshTableFootDelegate> delegate;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
@end
@protocol EGORefreshTableFootDelegate
- (void)egoRefreshTableFootDidTriggerRefresh:(EGORefreshTableFootView*)view;
- (BOOL)egoRefreshTableFootDataSourceIsLoading:(EGORefreshTableFootView*)view;
@optional
- (NSDate*)egoRefreshTableFootDataSourceLastUpdated:(EGORefreshTableFootView*)view;
@end
