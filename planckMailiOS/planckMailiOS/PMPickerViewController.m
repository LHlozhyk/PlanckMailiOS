//
//  PMPickerViewController.m
//  planckMailiOS
//
//  Created by nazar on 11/2/15.
//  Copyright © 2015 Nazar Stadnytsky. All rights reserved.
//

#import "PMPickerViewController.h"

@interface PMPickerViewController ()
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation PMPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.baseView.layer.cornerRadius = 10.f;
    self.baseView.layer.masksToBounds = YES;
    [self.baseView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.baseView.layer setBorderWidth:2];
    
    self.dateLabel.text = @"Month Year";
    
    NSDate *date = [NSDate date];
    date = [NSDate date];
    self.datePicker.minimumDate = date;
    
    
    
    int difference = [self getDifference];
    
    NSDate *maximumDate = [date dateByAddingTimeInterval:60*60*24*difference];
    self.datePicker.maximumDate = maximumDate;
    [self.datePicker setValue:[UIColor whiteColor] forKeyPath:@"textColor"];
    self.datePicker.backgroundColor = [UIColor clearColor];
    self.baseView.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)previousMonthAction:(id)sender {
 
    NSDate *date = self.datePicker.date;
    
    date = [date dateByAddingTimeInterval:-(60*60*24*30)];
    [self.datePicker setDate:date animated:YES];
    [self reloadPickerLabel];

}

- (IBAction)nextMonthAction:(id)sender {
    
    NSDate *date = self.datePicker.date;

  
    date = [date dateByAddingTimeInterval:60*60*24*30];
    [self.datePicker setDate:date animated:YES];
    [self reloadPickerLabel];

}

- (IBAction)datePickerIsChanged:(id)sender {
   
    [self reloadPickerLabel];
}

- (IBAction)setDateAction:(id)sender {
    

    
    if ([_delegate respondsToSelector:@selector(PMPickerViewController:setDate:)]) {
        [self dismissViewControllerAnimated:YES completion:NULL];

        [_delegate PMPickerViewController:self setDate:self.datePicker.date];

    }
    
}

- (IBAction)cancelAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    
    if ([_delegate respondsToSelector:@selector(PMPickerViewControllerDismiss:)]) {
        [_delegate PMPickerViewControllerDismiss:self];
    }
}

#pragma mark - NSDate stuff

-(NSString*)getMonthName {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM:YYYY"];

    NSString *month = [dateFormatter stringFromDate:self.datePicker.date];
    int monthNumber = [month intValue];
    NSString *monthName = [dateFormatter monthSymbols][monthNumber-1];
    
    return monthName;
}

-(NSString *)getStringDate {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY"];
    
    NSString *year = [dateFormatter stringFromDate:self.datePicker.date];
    
    return [NSString stringWithFormat:@"%@ %@", [self getMonthName], year];

}

-(int)getDifference {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    
    NSString *day = [dateFormatter stringFromDate:[NSDate date]];
    
    int intDay = [day intValue];
    
    NSRange dayRange = [[NSCalendar currentCalendar]
                        rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self.datePicker.date];
    
    int difference = (int)dayRange.length - intDay;
    
    return difference+31;
}

#pragma mark - Other stuff

-(void)reloadPickerLabel {
    
    self.dateLabel.text = [self getStringDate];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
