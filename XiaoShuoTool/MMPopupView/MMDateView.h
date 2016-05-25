//
//  MMDateView.h
//  MMPopupView
//
//  Created by Ralph Li on 9/7/15.
//  Copyright © 2015 LJC. All rights reserved.
//

#import "MMPopupView.h"
#import "ZMFTDefines.h"

typedef void(^MMPopupDateHandler)(NSDate *date);
@interface MMDateView : MMPopupView

- (instancetype)initWithDefaultDate:(NSDate *)date
                        minimumDate:(NSDate *)minDate
                        maximumDate:(NSDate *)maxDate
                            handler:(MMPopupDateHandler)dateHandler;

@end

typedef void(^MMPopupPeriodHandle)(NSInteger period, ZMPeriodUnit unit);

@interface MMPeriodView : MMPopupView

- (instancetype)initWithPeriod:(NSInteger)period unit:(ZMPeriodUnit)unit handle:(MMPopupPeriodHandle)periodHandle;

@end
