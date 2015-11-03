//
//  PMBoxFileListViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMBoxFileListViewController.h"

#import "PMBoxFileViewController.h"

@interface PMBoxFileListViewController ()
{
    
}

@property (nonatomic, readwrite, strong) NSArray *items;
@property (nonatomic, readwrite, strong) BOXFolder *folder;
@property (nonatomic, readwrite, strong) BOXRequest *request;
@property (nonatomic, readwrite, strong) BOXFileThumbnailRequest *thumbnailRequest;

@end

@implementation PMBoxFileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(!_folderID)
        _folderID = BOXAPIFolderIDRoot;
    
    // Get the current folder's informations
    BOXFolderRequest *folderRequest = [self.client folderInfoRequestWithID:self.folderID];
    [folderRequest performRequestWithCompletion:^(BOXFolder *folder, NSError *error) {
        self.folder = folder;
    }];
    
    [self loadItems];
    
    
    
    
    NSString *title = !self.folderName?@"Your Box":self.folderName;
    [self setNavigationBar:title];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)loadItems
{
    [self showLoadingProgressBar];
    
    
    // Retrieve all items from the folder.
    BOXFolderItemsRequest *itemsRequest = [self.client folderItemsRequestWithID:self.folderID];
    itemsRequest.requestAllItemFields = YES;
    [itemsRequest performRequestWithCompletion:^(NSArray *items, NSError *error) {
        if (error == nil) {
            self.items = items;
            
            
            [self.tblFileList reloadData];
        }
        [self hideLoadingProgressBar];
    }];
    
    self.request = itemsRequest;
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
    
    BOXItem *item = self.items[indexPath.row];
    
    cell.lblFileName.text = item.name;
    
    cell.lblModifiedTime.text = [NSString stringWithFormat:@"Modified at %@", [PMFileManager RelativeTime:[item.modifiedDate timeIntervalSince1970]]];
    
    NSString *iconName;
    
    UIImage *icon;
    if([item isKindOfClass:[BOXFolder class]])
    {
        cell.lblFileSize.hidden = YES;
        CGRect iconSize = cell.imgThumbnail.frame;
        CGRect newSize = CGRectMake(iconSize.origin.x, iconSize.origin.y+15, iconSize.size.width, iconSize.size.height);
        cell.frame = newSize;
        
        icon = [UIImage imageNamed:@"folder.png"];
    }
    else
    {
        cell.lblFileSize.text = [PMFileManager FileSizeAsString:[((BOXFile*)item).size longLongValue]];
        
        NSString *ext = [[item.name pathExtension] lowercaseString];
        icon = [UIImage imageNamed:[PMFileManager IconFileByExt:ext]];
        
        if([PMFileManager IsThumbnailAbaliable:item.name])
        {
            UIImage *thumbnail = [UIImage imageWithContentsOfFile:[[PMFileManager ThumbnailDirectory:@"Box"] stringByAppendingPathComponent:item.name]];
            
            if(thumbnail)
            {
                icon = thumbnail;
            }
            else
            {
                self.thumbnailRequest = [self.client fileThumbnailRequestWithID:item.modelID size:BOXThumbnailSize64];
                __weak PMFileViewCell *weakCell = cell;
                
                [self.thumbnailRequest performRequestWithProgress:nil completion:^(UIImage *image, NSError *error) {
                    if (error == nil) {
                        NSData *imageData = UIImagePNGRepresentation(image);
                        [imageData writeToFile:[[PMFileManager ThumbnailDirectory:@"Box"] stringByAppendingPathComponent:item.name] atomically:YES];
                        
                        // fade animation transition effect
                        weakCell.imgThumbnail.image = image;
                        CATransition *transition = [CATransition animation];
                        transition.duration = 0.3f;
                        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                        transition.type = kCATransitionFade;
                        [weakCell.imgThumbnail.layer addAnimation:transition forKey:nil];
                    }
                    else
                    {
                        NSLog(@"%@", error);
                    }
                }];
            }
        }
    }
    
    
    cell.imgThumbnail.image = icon;    
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOXItem *item = self.items[indexPath.row];
    UIViewController *controller = nil;
    
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    if ([item isKindOfClass:[BOXFolder class]]) {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMBoxFileListViewController"];
        ((PMBoxFileListViewController*)controller).client = self.client;
        ((PMBoxFileListViewController*)controller).folderID = item.modelID;
        ((PMBoxFileListViewController*)controller).folderName = item.name;
        ((PMBoxFileListViewController*)controller).isSelecting = self.isSelecting;
        
    } else {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMBoxFileViewController"];
        ((PMBoxFileViewController*)controller).client = self.client;
        ((PMBoxFileViewController*)controller).itemID = item.modelID;
        ((PMBoxFileViewController*)controller).itemType = item.type;
        ((PMBoxFileViewController*)controller).isSelecting = self.isSelecting;
    }
    [self.navigationController pushViewController:controller animated:YES];
}

/*- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BOXItem *item = self.items[indexPath.row];
        NSString *message = [NSString stringWithFormat:@"This will delete \n%@\nAre you sure you wish to continue ?", item.name];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        alertView.tag = indexPath.row;
        [alertView show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        BOXItem *item = self.items[alertView.tag];
        
        BOXErrorBlock errorBlock = ^void(NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Could not delete this item."  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alertView show];
            } else {
                NSMutableArray *array = [NSMutableArray arrayWithArray:self.items];
                [array removeObject:item];
                self.items = [array copy];
                [self.tableView reloadData];
            }
        };
        
        if ([item isKindOfClass:[BOXFolder class]]) {
            BOXFolderDeleteRequest *request = [self.client folderDeleteRequestWithID:item.modelID];
            [request performRequestWithCompletion:^(NSError *error) {
                errorBlock (error);
            }];
        } else if ([item isKindOfClass:[BOXFile class]]) {
            BOXFileDeleteRequest *request = [self.client fileDeleteRequestWithID:item.modelID];
            [request performRequestWithCompletion:^(NSError *error) {
                errorBlock (error);
            }];
        } else if ([item isKindOfClass:[BOXBookmark class]]) {
            BOXBookmarkDeleteRequest *request = [self.client bookmarkDeleteRequestWithID:item.modelID];
            [request performRequestWithCompletion:^(NSError *error) {
                errorBlock (error);
            }];
        }
    }
}

#pragma mark - Callbacks

- (void)uploadAction:(id)sender
{
    // See the progress
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    BOXSampleProgressView *progressHeaderView = [[BOXSampleProgressView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), 50.0f)];
    self.tableView.tableHeaderView = progressHeaderView;
    
    NSString *dummyImageName = @"Logo_Box_Blue_Whitebg_480x480.jpg";
    
    // check if the file is already in the current folder, if it is, we need to upload a new version instead of performing a regular upload.
    NSInteger indexOfFile = NSNotFound;
    NSString *fileID = nil;
    for (BOXItem *item in self.items) {
        if ([item.name isEqualToString:dummyImageName]) {
            indexOfFile = [self.items indexOfObject:item];
            fileID = item.modelID;
            break;
        }
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:dummyImageName ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    // Create our blocks
    BOXFileBlock completionBlock = ^void(BOXFile *file, NSError *error) {
        if (error == nil) {
            [self updateDataSourceWithNewFile:file atIndex:indexOfFile];
            [self.tableView reloadData];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Upload Failed" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
        self.tableView.tableHeaderView = nil;
    };
    BOXProgressBlock progressBlock = ^void(long long totalBytesTransferred, long long totalBytesExpectedToTransfer)
    {
        progressHeaderView.progressView.progress = (float)totalBytesTransferred / (float)totalBytesExpectedToTransfer;
    };
    
    // We did not find a file named similarly, we can upload normally the file.
    if (indexOfFile == NSNotFound) {
        BOXFileUploadRequest *uploadRequest = [self.client fileUploadRequestToFolderWithID:self.folderID fromData:data fileName:dummyImageName];
        uploadRequest.enableCheckForCorruptionInTransit = YES;
        [uploadRequest performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
            progressBlock(totalBytesTransferred, totalBytesExpectedToTransfer);
        } completion:^(BOXFile *file, NSError *error) {
            completionBlock(file, error);
        }];
    }
    // We already found the item. We will upload a new version of the file.
    // Alternatively, we can also rename the file and upload it like a regular new file via a BOXFileUploadRequest
    else {
        BOXFileUploadNewVersionRequest *newVersionRequest = [self.client fileUploadNewVersionRequestWithID:fileID fromData:data];
        [newVersionRequest performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
            progressBlock(totalBytesTransferred, totalBytesExpectedToTransfer);
        } completion:^(BOXFile *file, NSError *error) {
            completionBlock(file, error);
        }];
    }
}

- (void)importAction:(id)sender
{
    //This method allows us to import media from library using the Photos framework. Once we get the fileURLs of selected assets,
    //we can invoke the upload request provided ContentSDK.
    __weak BOXSampleFolderViewController *weakSelf = self;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    BOXSampleLibraryAssetViewController *libraryAssetViewController = [[BOXSampleLibraryAssetViewController alloc] initWithCollectionViewLayout:layout];
    
    libraryAssetViewController.assetSelectionCompletionBlock = ^(NSArray *selectedPHAssetLocalPaths) {
        for (NSURL *filePath in selectedPHAssetLocalPaths) {
            
            BOXFileUploadRequest *uploadRequest = [weakSelf.client fileUploadRequestToFolderWithID:weakSelf.folderID fromLocalFilePath:filePath.path];
            uploadRequest.enableCheckForCorruptionInTransit = YES;
            [uploadRequest performRequestWithProgress:nil completion:^(BOXFile *file, NSError *error) {
                
                if (error == nil) {
                    [weakSelf updateDataSourceWithNewFile:file atIndex:NSNotFound];
                    [weakSelf.tableView reloadData];
                } else if (error.code == BOXContentSDKAPIErrorConflict) {
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Name conflict" message:@"File with same name already exists"  preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                    [weakSelf presentViewController:alert animated:YES completion:nil];
                }
            }];
        }
    };
    
    [self.navigationController pushViewController:libraryAssetViewController animated:YES];
}*/

#pragma mark - Private Helpers

- (void)updateDataSourceWithNewFile:(BOXFile *)file atIndex:(NSInteger)index
{
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.items];
    if (index == NSNotFound) {
        [newItems addObject:file];
    } else {
        [newItems replaceObjectAtIndex:index withObject:file];
    }
    self.items = newItems;
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
