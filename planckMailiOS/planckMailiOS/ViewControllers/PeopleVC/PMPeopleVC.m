//
//  PMPeopleVC.m
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMPeopleVC.h"
#import "CLContactLibrary.h"
#import "PMPreviewPeopleVC.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#define CELL_IDENTIFIER @"peopleCell"

#define LETTERS @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#"];

@interface PMPeopleVC () <APContactLibraryDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
    NSArray *_itemsArray;
    
    NSArray *_itemsArrayFiltered;

    UISearchBar *_searchBar;
    BOOL filtered;
}
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation PMPeopleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _itemsArray = [NSArray new];
    _itemsArrayFiltered = [NSArray new];
    
    [[CLContactLibrary sharedInstance] setDelegate:self];
    [[CLContactLibrary sharedInstance] getContactArrayForDelegate:self];
    
    //delete empty separate lines for tableView
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [_searchBar setDelegate:self];
    [_searchBar setPlaceholder:@"Search"];
    [_searchBar setTintColor:[UIColor whiteColor]];
    [_searchBar setBarTintColor:[UIColor whiteColor]];
    
    [_searchBar setImage:[UIImage imageNamed:@"searchIcon"]
                forSearchBarIcon:UISearchBarIconSearch
                           state:UIControlStateNormal];
    
    UITextField *searchTextField = [_searchBar valueForKey:@"_searchField"];
    searchTextField.textColor = [UIColor whiteColor];
    if ([searchTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        [searchTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: color}]];
    }
    
    self.navigationItem.titleView = _searchBar;
    
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"searhBarBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal];
}

- (void)apGetContactArray:(NSArray *)contactArray {
    _itemsArray = contactArray;
    
    [_tableView reloadData];
    NSLog(@"contactArray - %@", contactArray);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureCell:(UITableViewCell *)cell {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (filtered) {
        return [_itemsArrayFiltered count];
    } else {
        return [_itemsArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *lTableViewCell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
    if (lTableViewCell == nil) {
        lTableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    
    CLPerson *lNewPerson;
    
    if (filtered) {
        lNewPerson = [_itemsArrayFiltered objectAtIndex:indexPath.row];
    } else {
        lNewPerson = [_itemsArray objectAtIndex:indexPath.row];
    }
    
    lTableViewCell.textLabel.text = lNewPerson.fullName;
    
    return lTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return LETTERS;
}

#pragma mark - SearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self processSearch:searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self processSearch:searchBar.text];
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:NO];
    return YES;
}

- (void)processSearch:(NSString*)text {
    if ([text isEqualToString:@""]) {
        filtered = NO;
        [_tableView reloadData];
    } else {
        // Filter the array using NSPredicate
        NSString *match = [NSString stringWithFormat: @"%@%@", text, @"*"] ;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fullName like[cd]  %@)", match];
        _itemsArrayFiltered = [_itemsArray filteredArrayUsingPredicate:predicate];
        filtered = YES;
        [_tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    filtered = NO;
    [_tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NSStringFromClass([PMPreviewPeopleVC class])]) {
        [_searchBar resignFirstResponder];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        CLPerson *lNewPerson =  (filtered) ? [_itemsArrayFiltered objectAtIndex:indexPath.row] : [_itemsArray objectAtIndex:indexPath.row];
        PMPreviewPeopleVC *lPreviewPeople = segue.destinationViewController;
        lPreviewPeople.currentPerson = lNewPerson;
    }
}

@end
