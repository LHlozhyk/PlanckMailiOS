//
//  PMLocalFileListViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMLocalFileListViewController.h"
#import "PMLocalFileViewController.h"
#import "PMFileManager.h"
#import "PMFileItem.h"

@interface PMLocalFileListViewController ()
@property NSMutableArray *items;
@end

@implementation PMLocalFileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *title;
    if(!_path)
    {
        title = @"Your Mobile";
        _path = @"";
    }
    else
        title = [_path lastPathComponent];
    
    [self setNavigationBar:title];
    
    _absolutePath = [[PMFileManager MobileDirectory] stringByAppendingPathComponent:_path];
    
    [self loadItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadItems
{
    if(_items==nil) _items = [[NSMutableArray alloc] init];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_absolutePath error:nil];
    for(NSString *name in contents)
    {
        PMFileItem *item = [[PMFileItem alloc] init];
        
        item.name = name;
        item.path = [_path stringByAppendingPathComponent:name];
        item.fullpath = [_absolutePath stringByAppendingPathComponent:name];
        NSError *error;
        NSDictionary<NSString *,id> *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[_absolutePath stringByAppendingPathComponent:name] error:&error];
        
        if(error==nil)
        {
            item.size = [attributes fileSize];
            item.modifiedTime = [attributes fileModificationDate];
            item.isDirectory = [[attributes fileType] isEqualToString:NSFileTypeDirectory];
            item.type = [attributes fileType];
        }
        
        [_items addObject:item];
        
    }
    
    [self.tblFileList reloadData];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PMFileViewCell *cell = [self.tblFileList dequeueReusableCellWithIdentifier:@"PMFileViewCellID"];
    if (cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PMFileViewCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    PMFileItem *item = self.items[indexPath.row];
    
    cell.lblFileName.text = item.name;
    
    cell.lblModifiedTime.text = [NSString stringWithFormat:@"Modified at %@", [PMFileManager RelativeTime:[item.modifiedTime timeIntervalSince1970]]];
    
    UIImage *icon;
    
    if(item.isDirectory)
    {
        cell.lblFileSize.hidden = YES;
        CGRect iconSize = cell.imgThumbnail.frame;
        CGRect newSize = CGRectMake(iconSize.origin.x, iconSize.origin.y+15, iconSize.size.width, iconSize.size.height);
        cell.frame = newSize;
        
        icon = [UIImage imageNamed:@"folder.png"];
    }
    else
    {
        cell.lblFileSize.text = [PMFileManager FileSizeAsString:item.size];
        
        
        icon = [UIImage imageNamed:[PMFileManager IconFileByExt:[[item.name pathExtension] lowercaseString]]];
        
        
        if([PMFileManager IsThumbnailAbaliable:item.name])
        {
            
            UIImage *thumbnail = [PMFileManager ThumbnailFromFile:[[PMFileManager MobileDirectory] stringByAppendingPathComponent:item.path]];
            if(thumbnail)
                icon = thumbnail;
            
        }
        
        
    }
    
    
    cell.imgThumbnail.image = icon;
    
    
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PMFileItem *item = self.items[indexPath.row];
    UIViewController *controller = nil;
    
    if (item.isDirectory) {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMLocalFileListViewController"];
        ((PMLocalFileListViewController*)controller).path = item.path;
        
        ((PMLocalFileListViewController*)controller).isSelecting = self.isSelecting;
        
    } else {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMLocalFileViewController"];
        ((PMLocalFileViewController*)controller).fileitem = item;
        
        ((PMLocalFileViewController*)controller).isSelecting = self.isSelecting;
    }
    [self.navigationController pushViewController:controller animated:YES];
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
