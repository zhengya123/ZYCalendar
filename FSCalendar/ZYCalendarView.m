//
//  ZYCalendarView.m
//  MasonryDemo
//
//  Created by 郑亚 on 2018/9/27.
//  Copyright © 2018年 郑亚. All rights reserved.
//

#import "ZYCalendarView.h"
#import "FSCalendar.h"
#define ZY_SCreenH [UIScreen mainScreen].bounds.size.height
#define ZY_SCreenW [UIScreen mainScreen].bounds.size.width
#define CalendarHeight 350
#define cancelHeight   440
@interface ZYCalendarView ()<FSCalendarDataSource, FSCalendarDelegate>

@property (nonatomic, weak) FSCalendar * calendar;
@property (nonatomic, copy) NSDate * BeginDate;
@property (nonatomic, copy) NSDate * EndDate;
@property (nonatomic, strong) UILabel  * cancelLabel;
@property (nonatomic, assign) BOOL SelectAction;
@property (nonatomic, strong) NSDateFormatter * dateFormatter;

@end

@implementation ZYCalendarView
{
    NSString * _type;
}

+ (ZYCalendarView *)shareView{
    static ZYCalendarView * zycalendarView;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        zycalendarView = [[ZYCalendarView alloc]init];
    });
    return zycalendarView;
    
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(0, 0, ZY_SCreenW, ZY_SCreenH);
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self addSubview:self.cancelLabel];
        
        FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 350, self.frame.size.width, 300)];
        calendar.dataSource = self;
        calendar.delegate = self;
        calendar.backgroundColor = [UIColor whiteColor];
        calendar.allowsMultipleSelection = YES;
        calendar.scope = FSCalendarScopeMonth;
        calendar.appearance.headerMinimumDissolvedAlpha = 0;
        calendar.appearance.headerDateFormat = @"yyyy年MM月";
        calendar.appearance.titleWeekendColor = colorWithRGBString(navColor);
        calendar.appearance.weekdayTextColor = [UIColor whiteColor];
        calendar.appearance.headerTitleColor = [UIColor blackColor];
        calendar.appearance.todayColor = colorWithRGBString(navColor);
        calendar.appearance.selectionColor = colorWithRGBString(navColor);
        [self addSubview:calendar];
        self.calendar = calendar;
        
        UIButton * leftMonthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftMonthBtn setImage:[UIImage imageNamed:@"ZYCalceldarMonthLeft"] forState:UIControlStateNormal];
        leftMonthBtn.frame = CGRectMake(20, 15, 20, 20);
        [leftMonthBtn setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
        [leftMonthBtn addTarget:self action:@selector(leftMonthBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.calendar addSubview:leftMonthBtn];
        
        
        UIButton * rightMonthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightMonthBtn setImage:[UIImage imageNamed:@"ZYCalceldarMonthRight"] forState:UIControlStateNormal];
        rightMonthBtn.frame = CGRectMake(self.frame.size.width - 40, 15, 20, 20);
        [rightMonthBtn setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
        [rightMonthBtn addTarget:self action:@selector(rightMonthBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.calendar addSubview:rightMonthBtn];
        
        UIButton * leftYearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftYearBtn setImage:[UIImage imageNamed:@"ZYCalceldarYearLeft"] forState:UIControlStateNormal];
        leftYearBtn.frame = CGRectMake(70, 15, 20, 20);
        [leftYearBtn addTarget:self action:@selector(leftYearBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.calendar addSubview:leftYearBtn];
        
        UIButton * rightYearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightYearBtn setImage:[UIImage imageNamed:@"ZYCalceldarYearRight"] forState:UIControlStateNormal];
        rightYearBtn.frame = CGRectMake(self.frame.size.width - 90, 15, 20, 20);
        [rightYearBtn addTarget:self action:@selector(rightYearBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.calendar addSubview:rightYearBtn];
    }
    return self;
}
- (void)showView:(UIView *)addV Delegate:(id<ZYCalendarDelegate>)delegate type:(NSString *)type{
    _type = type;
    self.delegate = delegate;
    [addV addSubview:self];
    
    __weak typeof(self) weakSelf = self;
    self.calendar.frame = CGRectMake(0, self.frame.size.height, ZY_SCreenW, CalendarHeight);
    self.cancelLabel.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 30);
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 1;
        weakSelf.calendar.frame = CGRectMake(0, self.frame.size.height - CalendarHeight - PhoneNavHeigh(), ZY_SCreenW, CalendarHeight);
        weakSelf.cancelLabel.frame = CGRectMake(0, self.frame.size.height - cancelHeight, self.frame.size.width, 30);
    } completion:nil];
    
}
- (void)hidens{
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 0.0;
        weakSelf.calendar.frame = CGRectMake(0, self.frame.size.height, ZY_SCreenW, 0);
        weakSelf.cancelLabel.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 0);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hidens];
}

-(void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition

{
    if ([self compareOneDay:self.EndDate withAnotherDay:self.BeginDate] == 1) {
        
    }else{
        if ([self compareOneDay:self.BeginDate withAnotherDay:date] == 1) {
            NSLog(@"不能选择小于当前时间");
            [[MessageView sharedMessage] showFlashMessage:@"不能小于开始时间"];
            [calendar deselectDate:date];
            return;
        }else{

        }
    }
    
    if (!self.SelectAction) {
        
        NSArray *selectArrray =[calendar selectedDates];
        for (NSDate *select in selectArrray) {
            [calendar deselectDate:select];
        }
        
        [calendar selectDate:date];
        self.SelectAction=YES;
        self.BeginDate=date;
        self.EndDate=nil;
        [calendar reloadData];
        
    }else{
        
        NSInteger number =[self numberOfDaysWithFromDate:self.BeginDate toDate:date];
        if (number == 0) {
            self.BeginDate = date;
            self.EndDate = nil;
            [self.calendar reloadData];
            self.SelectAction = YES;
        }else if (number<0) {
            
            self.SelectAction=YES;
            [calendar deselectDate:date];
            self.BeginDate = date;
            [calendar reloadData];
            
        }else{
            
            self.SelectAction=NO;
            self.EndDate=date;
            
            for (int i = 0; i<number; i++) {
                [calendar selectDate:[date dateByAddingTimeInterval:-i*60*60*24]];
            }
        }
        [calendar reloadData];
    }
    
    if (self.BeginDate == nil || self.EndDate == nil) {
        
    }else{
       [self.delegate ZYCalendarDelegate:[self.dateFormatter stringFromDate:self.BeginDate] endT:[self.dateFormatter stringFromDate:self.EndDate]];
    }
    
    if ([self.dateFormatter stringFromDate:self.BeginDate].length > 0 && [self.dateFormatter stringFromDate:self.EndDate].length > 0) {
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            
            [self hidens];
            
        });
    }
}
- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    NSInteger number =[self numberOfDaysWithFromDate:self.BeginDate toDate:self.EndDate];
    for (int i = 0; i<number + 1; i++) {
        
        [_calendar deselectDate:[self.BeginDate dateByAddingTimeInterval:i*60*60*24]];
        
    }
    self.BeginDate = nil;
    self.EndDate = nil;
    [self.calendar reloadData];
}
- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date{
    
    if ([[NSCalendar currentCalendar] isDateInToday:date]){
        return @"今";
    }
    
    if (self.SelectAction) {
        if ([[self.dateFormatter stringFromDate:self.BeginDate] isEqualToString:[self.dateFormatter stringFromDate:date]]) {
            return @"开始";
        }else{
            return nil;
        }
        
    }else{
        
        if ([[self.dateFormatter stringFromDate:self.BeginDate] isEqualToString:[self.dateFormatter stringFromDate:date]]) {
            return @"开始";
        }else if ([[self.dateFormatter stringFromDate:self.EndDate] isEqualToString:[self.dateFormatter stringFromDate:date]]){
            return @"结束";
        }else{
            return nil;
        }
    }
    return nil;
    
}
- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar{
    NSString * maxDateStr = getNowDateWithStyle(@"yyyy-MM-dd");
    return [self.dateFormatter dateFromString:maxDateStr];
    
}
- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    //获取前一个年的时间
    NSDate *monthagoData = [self getPriousorLaterDateFromDate:currentDate withMonth:-1];
    NSString * minDateStr = @"2017-01-01";
    return [self.dateFormatter dateFromString:minDateStr];
    
}
-(NSInteger)numberOfDaysWithFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents * comp = [calendar components:NSCalendarUnitDay
                                          fromDate:fromDate
                                            toDate:toDate options:NSCalendarWrapComponents];
    
    return comp.day;
    
}

- (void)leftMonthBtnClick:(UIButton *)btn{
    NSDate *nextMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:self.calendar.currentPage options:0];

    [self.calendar setCurrentPage:nextMonth animated:YES];

}
- (void)rightMonthBtnClick:(UIButton *)btn{
        NSDate *nextMonths = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:self.calendar.currentPage options:0];

        [self.calendar setCurrentPage:nextMonths animated:YES];
}
- (void)leftYearBtnClick:(UIButton *)btn{
    NSDate *nextMonth = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitYear value:-1 toDate:self.calendar.currentPage options:0];
    
    [self.calendar setCurrentPage:nextMonth animated:NO];
}
- (void)rightYearBtnClick:(UIButton *)btn{
    NSDate *nextMonths = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitYear value:1 toDate:self.calendar.currentPage options:0];
    
    [self.calendar setCurrentPage:nextMonths animated:NO];
    
}
-(int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    
    NSComparisonResult result = [dateA compare:dateB];
    
    if (result == NSOrderedDescending) {
        return 1;
    }
    else if (result == NSOrderedAscending){
        return -1;
    }
    return 0;
    
}
-(NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withMonth:(int)month{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    //[comps setMonth:month];
    [comps setYear:month];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];// NSGregorianCalendar
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:date options:0];
    return mDate;
}
- (NSDateFormatter *)dateFormatter{
    if (_dateFormatter == nil) {
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setDateFormat: @"YYYY-MM-dd"];
    }
    return _dateFormatter;
}
- (UILabel *)cancelLabel{
    if (_cancelLabel == nil) {
        _cancelLabel = [UILabel new];
        _cancelLabel.textAlignment = NSTextAlignmentCenter;
        _cancelLabel.text = @"轻触取消";
        _cancelLabel.font = [UIFont systemFontOfSize:12];
        _cancelLabel.textColor = [UIColor whiteColor];
    }
    return _cancelLabel;
}
@end
