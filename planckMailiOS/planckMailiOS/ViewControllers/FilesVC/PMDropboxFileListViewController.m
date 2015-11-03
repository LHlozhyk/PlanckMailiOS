//
//  PMDropBoxFileListViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/24/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMDropboxFileListViewController.h"
#import "PMDropboxFileViewController.h"

@interface PMDropboxFileListViewController ()
{
    
}
@end

@implementation PMDropboxFileListViewController
@synthesize loadData;
@synthesize tblFileList;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!loadData) {
        loadData = @"";
    }
    
    if(loadData)
    arrayFiles = [[NSMutableArray alloc] init];
    arrayFolders = [[NSMutableArray alloc] init];
    arrayThumbnails = [[NSMutableArray alloc] init];
    
    
    
    [self performSelector:@selector(loadItems) withObject:nil afterDelay:.1];
    
    
    
    //tblFileList.rowHeight = UITableViewAutomaticDimension;
    //tblFileList.estimatedRowHeight = 80.0;
    
    NSString *title;
    if([loadData isEqualToString:@""])
        title = @"Your Dropbox";
    else
    {
        NSArray *token = [loadData pathComponents];
        title = [token lastObject];
    }
    [self setNavigationBar:title];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Dropbox Methods
- (DBRestClient *)restClient
{
    if (restClient == nil) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    
    return restClient;
}

-(void)loadItems
{
    [self showLoadingProgressBar];
    
    [self.restClient loadMetadata:loadData];
}


#pragma mark - DBRestClientDelegate Methods for Load Data
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata *)metadata
{
    for (int i = 0; i < [metadata.contents count]; i++) {
        DBMetadata *data = [metadata.contents objectAtIndex:i];
        
        
        [arrayFiles addObject:data];
        
        
        if(data.isDirectory)
        {
            [arrayThumbnails addObject:@"folder.png"];
        }
        else
        {
            NSString *filename = data.filename;
            NSString *ext = [[filename pathExtension] lowercaseString];
            [arrayThumbnails addObject:[PMFileManager IconFileByExt:ext]];
            
            if(data.thumbnailExists)
            {
                NSString *localThumbnailPath = [[PMFileManager ThumbnailDirectory:@"Dropbox"] stringByAppendingPathComponent:data.filename];
                [restClient loadThumbnail: data.path ofSize:@"l" intoPath:localThumbnailPath];
            }
        }
        
        
    }
    [tblFileList reloadData];
    [self hideLoadingProgressBar];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    [tblFileList reloadData];
    [self hideLoadingProgressBar];
}

#pragma mark - DBRestClientDelegate Methods for Download Data
- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)localPath
{
    
    [tblFileList reloadData];
}


#pragma mark - UITableView Delegate Methods
/*-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*int files = 0, folders = 0;
    
    for(int i=0; i<arrayFiles.count; i++)
    {
        DBMetadata *data = [arrayFiles objectAtIndex:i];
        if(data.isDirectory) folders++;
        else files++;
    }
    if(section == 0)
        return files;
    return folders;*/
    
    return arrayFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    DBMetadata *metadata = [arrayFiles objectAtIndex:indexPath.row];
    
    
    PMFileViewCell *cell = [tblFileList dequeueReusableCellWithIdentifier:@"PMFileViewCellID"];
    if (cell == nil)
    {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PMFileViewCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    cell.lblFileName.text = metadata.filename;
    
    UIImage *icon;
    NSString *thumbnailFile = [arrayThumbnails objectAtIndex:indexPath.row];
    icon = [UIImage imageNamed:thumbnailFile];
    
    cell.imgThumbnail.image = icon;
    if(metadata.thumbnailExists)
    {
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:[[PMFileManager ThumbnailDirectory:@"Dropbox"] stringByAppendingPathComponent:metadata.filename]];
        if(img!=nil) cell.imgThumbnail.image = img;
    }
    
    
    if(metadata.isDirectory)
    {
        cell.lblFileSize.hidden = YES;
        CGRect iconSize = cell.imgThumbnail.frame;
        CGRect newSize = CGRectMake(iconSize.origin.x, iconSize.origin.y+15, iconSize.size.width, iconSize.size.height);
        cell.frame = newSize;
    }
    else
    {
        cell.lblFileSize.text = metadata.humanReadableSize;
    }
    
    cell.lblModifiedTime.text = [NSString stringWithFormat:@"Modified at %@", [PMFileManager RelativeTime:[metadata.lastModifiedDate timeIntervalSince1970]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DBMetadata *metadata = [arrayFiles objectAtIndex:indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    UIViewController *controller;
    if(metadata.isDirectory)
    {
        controller = [storyboard instantiateViewControllerWithIdentifier:@"PMDropboxFileListViewController"];
        ((PMDropboxFileListViewController*)controller).loadData = metadata.path;
        ((PMDropboxFileListViewController*)controller).isSelecting = self.isSelecting;
    }
    else
    {
        controller = [storyboard instantiateViewControllerWithIdentifier:@"PMDropboxFileViewController"];
        
        ((PMDropboxFileViewController*)controller).fileitem = metadata;
        ((PMDropboxFileViewController*)controller).restClient = restClient;
        ((PMDropboxFileViewController*)controller).isSelecting = self.isSelecting;
        
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
