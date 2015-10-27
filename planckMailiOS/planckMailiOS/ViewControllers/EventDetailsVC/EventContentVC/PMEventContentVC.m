//
//  PMEventContentVC.m
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 10/13/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMEventContentVC.h"
#import "PMEventAlertVC.h"
#import "UIViewController+PMStoryboard.h"

#import "PMEventModel.h"

#import "NSDate+DateConverter.h"

@interface PMEventContentVC () {
    IBOutlet UILabel *_titleLabel;
    IBOutlet UILabel *_dateLabel;
    
    IBOutlet UITableViewCell *_placeCell;
    IBOutlet UITableViewCell *_timeCell;
    IBOutlet UITableViewCell *_inviteesCell;
    IBOutlet UITableViewCell *_organizerCell;
}
@property(nonatomic, strong) PMEventModel *currentEvent;
@end

@implementation PMEventContentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    NSDate *date = [NSDate date];
    NSString *lDuration = @"";
    
    switch (_currentEvent.eventDateType) {
        case EventDateTimeType: {
            date = [NSDate dateWithTimeIntervalSince1970:[_currentEvent.startTime doubleValue]];
        }
            break;
            
        case EventDateTimespanType: {
            date = [NSDate dateWithTimeIntervalSince1970:[_currentEvent.startTime doubleValue]];
            
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[_currentEvent.startTime doubleValue]];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[_currentEvent.endTime doubleValue]];
            
            lDuration  = [NSString stringWithFormat:@"%@ - %@", [startDate timeStringValue], [endDate timeStringValue]];
        }
            
            break;
            
        case EventDateDateType: {
            date = [NSDate eventDateFromString:_currentEvent.startTime];
            lDuration = @"All Day";
        }
            break;
            
        case EventDateDatespanType: {
            date = [NSDate eventDateFromString:_currentEvent.startTime];
            
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[_currentEvent.startTime doubleValue]];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[_currentEvent.endTime doubleValue]];
            
            lDuration  = [NSString stringWithFormat:@"%@\n%@", [startDate dateStringValue], [endDate dateStringValue]];
        }
            break;
            
        default:
            break;
    }
    _dateLabel.text = [NSString stringWithFormat:@"%@\n%@", [date dateStringValue], lDuration];
    
    _titleLabel.text = _currentEvent.title.length == 0 ? @"Untitled" : _currentEvent.title;
    
    if (_currentEvent.location.length != 0) {
        _placeCell.textLabel.text = _currentEvent.location;
    } else {
        [_placeCell setHidden:YES];
    }
    
    if (_currentEvent.owner.length != 0) {
        _organizerCell.textLabel.text = _currentEvent.owner;
    } else {
        [_organizerCell setHidden:YES];
    }
    
    [_timeCell setHidden:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateWithEvent:(PMEventModel *)event {
    _currentEvent = event;
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == _timeCell) {
        PMEventAlertVC *lEventAlertVC = [[PMEventAlertVC alloc] initWithStoryboard];
        [self.navigationController pushViewController:lEventAlertVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    if(cell.hidden) {
        return 0;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
