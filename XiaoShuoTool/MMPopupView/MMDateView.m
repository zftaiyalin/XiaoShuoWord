//
//  MMDateView.m
//  MMPopupView
//
//  Created by Ralph Li on 9/7/15.
//  Copyright © 2015 LJC. All rights reserved.
//

#import "MMDateView.h"
#import "MMPopupDefine.h"
#import "MMPopupCategory.h"
#import "Masonry.h"
#import "MMSheetView.h"

@interface MMDateView()

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIButton *btnCancel;
@property (nonatomic, strong) UIButton *btnConfirm;

@property (nonatomic, copy) MMPopupDateHandler dateHandler;

@end

@implementation MMDateView

- (instancetype)initWithDefaultDate:(NSDate *)date
                        minimumDate:(NSDate *)minDate
                        maximumDate:(NSDate *)maxDate
                            handler:(MMPopupDateHandler)dateHandler {
    self = [super init];
    
    if (self) {
        MMSheetViewConfig *config = [MMSheetViewConfig globalConfig];
        
        self.type = MMPopupTypeSheet;
        self.dateHandler = dateHandler;
        self.backgroundColor = config.backgroundColor;
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
            make.height.mas_equalTo(216+50);
        }];
        
        self.btnCancel = [UIButton mm_buttonWithTarget:self action:@selector(actionHide:)];
        [self addSubview:self.btnCancel];
        [self.btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 50));
            make.left.top.equalTo(self);
        }];
        [self.btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:config.itemNormalColor forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:config.itemHighlightColor forState:UIControlStateHighlighted];
        self.btnCancel.tag = 0;
        
        self.btnConfirm = [UIButton mm_buttonWithTarget:self action:@selector(actionHide:)];
        [self addSubview:self.btnConfirm];
        [self.btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 50));
            make.right.top.equalTo(self);
        }];
        [self.btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
        [self.btnConfirm setTitleColor:config.itemNormalColor forState:UIControlStateNormal];
        [self.btnConfirm setTitleColor:config.itemHighlightColor forState:UIControlStateHighlighted];
        self.btnConfirm.tag = 1;
        
        self.datePicker = [UIDatePicker new];
        [self.datePicker setDatePickerMode:UIDatePickerModeDate];
        [self.datePicker setMinimumDate:minDate];
        if (date) { // setDate为空时，会crash
            [self.datePicker setDate:date];
        }
        [self.datePicker setMaximumDate:maxDate];
        [self addSubview:self.datePicker];
        [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(50, 0, 0, 0));
        }];
    }
    return self;
}

- (void)actionHide:(UIButton *)btn
{
    [self hide];
    
    if (self.dateHandler && btn.tag>0) {
        self.dateHandler(self.datePicker.date);
    }
}

//- (instancetype)init
//{
//    self = [super init];
//    
//    if ( self )
//    {
//        self.type = MMPopupTypeSheet;
//        
//        self.backgroundColor = [UIColor whiteColor];
//        
//        [self mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
//            make.height.mas_equalTo(216+50);
//        }];
//        
//        self.btnCancel = [UIButton mm_buttonWithTarget:self action:@selector(actionHide)];
//        [self addSubview:self.btnCancel];
//        [self.btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(80, 50));
//            make.left.top.equalTo(self);
//        }];
//        [self.btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
//        [self.btnCancel setTitleColor:MMHexColor(0xE76153FF) forState:UIControlStateNormal];
//        
//        
//        self.btnConfirm = [UIButton mm_buttonWithTarget:self action:@selector(actionHide)];
//        [self addSubview:self.btnConfirm];
//        [self.btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(80, 50));
//            make.right.top.equalTo(self);
//        }];
//        [self.btnConfirm setTitle:@"Confirm" forState:UIControlStateNormal];
//        [self.btnConfirm setTitleColor:MMHexColor(0xE76153FF) forState:UIControlStateNormal];
//        
//        self.datePicker = [UIDatePicker new];
//        [self addSubview:self.datePicker];
//        [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self).insets(UIEdgeInsetsMake(50, 0, 0, 0));
//        }];
//    }
//    
//    return self;
//}
//
//- (void)actionHide
//{
//    [self hide];
//}

@end

@interface MMPeriodView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *periodPicker;

@property (nonatomic, strong) UIButton *btnCancel;
@property (nonatomic, strong) UIButton *btnConfirm;

@property (nonatomic, copy) MMPopupPeriodHandle periodHandle;

@property (nonatomic, strong) NSArray *unitTitles;
@property (nonatomic, strong) NSArray *maxRowsOfUnit;
@property (nonatomic, assign) NSUInteger selectedUnit;

@end

@implementation MMPeriodView

- (instancetype)initWithPeriod:(NSInteger)period unit:(ZMPeriodUnit)unit handle:(MMPopupPeriodHandle)periodHandle {
    self = [super init];
    if (self) {
        _unitTitles = @[@"天", @"周", @"月"];
        _maxRowsOfUnit = @[@(32), @(4), @(12)];
        
        MMSheetViewConfig *config = [MMSheetViewConfig globalConfig];
        
        self.type = MMPopupTypeSheet;
        self.periodHandle = periodHandle;
        self.backgroundColor = config.backgroundColor;
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
            make.height.mas_equalTo(216+50);
        }];
        
        self.btnCancel = [UIButton mm_buttonWithTarget:self action:@selector(actionHide:)];
        [self addSubview:self.btnCancel];
        [self.btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 50));
            make.left.top.equalTo(self);
        }];
        [self.btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:config.itemNormalColor forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:config.itemHighlightColor forState:UIControlStateHighlighted];
        self.btnCancel.tag = 0;
        
        self.btnConfirm = [UIButton mm_buttonWithTarget:self action:@selector(actionHide:)];
        [self addSubview:self.btnConfirm];
        [self.btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 50));
            make.right.top.equalTo(self);
        }];
        [self.btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
        [self.btnConfirm setTitleColor:config.itemNormalColor forState:UIControlStateNormal];
        [self.btnConfirm setTitleColor:config.itemHighlightColor forState:UIControlStateHighlighted];
        self.btnConfirm.tag = 1;
        
        self.periodPicker = [UIPickerView new];
        self.periodPicker.delegate = self;
        self.periodPicker.dataSource = self;
        [self addSubview:self.periodPicker];
        [self.periodPicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(50, 0, 0, 0));
        }];
        
        
        if (unit!=ZMPeriodUnit_Day) {
            period = MAX(--period, 0);
        }
        _selectedUnit = unit;
        [_periodPicker selectRow:unit inComponent:1 animated:YES];
        [_periodPicker selectRow:period inComponent:0 animated:YES];
        
    }
    
    return self;
}

- (void)actionHide:(UIButton *)btn
{
    [self hide];
    
    if (self.periodHandle && btn.tag>0) {
        NSInteger periodIndex = [_periodPicker selectedRowInComponent:0];
        NSInteger unitIndex = [_periodPicker selectedRowInComponent:1];
        
        if (unitIndex!=0) {
            periodIndex++;
        }
        
        if (_periodHandle) {
            _periodHandle(periodIndex, unitIndex);
        }
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger count = 0;
    switch (component) {
        case 0: {
            count = [_maxRowsOfUnit[_selectedUnit] integerValue];
        }
            break;
            
        case 1: {
            count = _unitTitles.count;
        }
            break;
            
        default:
            break;
    }
    
    return count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = nil;
    switch (component) {
        case 0: {
            title = [NSString stringWithFormat:@"%ld", (_selectedUnit!=0)?(row+1):row];
        }
            break;
            
        case 1: {
            title = [_unitTitles objectAtIndex:row];
        }
            break;
            
        default:
            break;
    }
    
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component==1) {
        _selectedUnit = row;
        [pickerView reloadComponent:0];
        [pickerView selectRow:0 inComponent:0 animated:YES];
    }
}

@end