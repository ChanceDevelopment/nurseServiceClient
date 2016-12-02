//
// IQActionSheetPickerView.h
// Hobizbo
//
// Created by Binod_Mac on 11/5/13.
// Copyright (c) 2013 Hobizbo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum IQActionSheetPickerStyle
{
    IQActionSheetPickerStyleTextPicker,
    IQActionSheetPickerStyleDatePicker
}IQActionSheetPickerStyle;

@class IQActionSheetPickerView;

@protocol IQActionSheetPickerView <UIActionSheetDelegate>

- (void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray*)titles;
- (void)myactionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface IQActionSheetPickerView : UIActionSheet<UIPickerViewDataSource,UIPickerViewDelegate>
{
//@private
    
    
}

@property(nonatomic, strong)UIDatePicker    *datePicker;
@property(nonatomic, strong)UIToolbar       *actionToolbar;

@property(nonatomic,assign) id<IQActionSheetPickerView> delegate; // weak reference
@property(nonatomic, assign) IQActionSheetPickerStyle actionSheetPickerStyle;   //Default is IQActionSheetPickerStyleTextPicker;

/*for IQActionSheetPickerStyleTextPicker*/
@property(nonatomic,assign) BOOL isRangePickerView;
@property(nonatomic, strong) NSArray *titlesForComponenets;
@property(nonatomic, strong) NSArray *widthsForComponents;
@property(nonatomic, strong) IBOutlet UIPickerView    *_pickerView;

/*for IQActionSheetPickerStyleDatePicker*/
@property(nonatomic, assign) NSDateFormatterStyle dateStyle;    //returning date string style.

-(id)initWithTitle:(NSString *)title date:(NSString*)dateString delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end