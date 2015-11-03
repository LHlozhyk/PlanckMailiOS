//
//  PMFilePreviewViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/31/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFilePreviewViewController.h"
#import "PMFileManager.h"
#import "PMNetworkManager.h"
#import "PMAPIManager.h"
#import <AFNetworking/UIProgressView+AFNetworking.h>

#import <DropboxSDK/DropboxSDK.h>
#import <BoxContentSDK/BOXContentSDK.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import <OneDriveSDK/OneDriveSDK.h>

#import "PMMailComposeVC.h"
#import "Config.h"

#import "AlertManager.h"

#define UPLOADING "Uploading..."

@interface PMFilePreviewViewController ()<DBRestClientDelegate>
{
    DBRestClient *dropboxClient;
    BOXContentClient *boxClient;
    GTLServiceDrive *gtlService;
    ODClient *onedriveClient;

}


@property (weak, nonatomic) IBOutlet UILabel *lblFileName;
@property (weak, nonatomic) IBOutlet UILabel *lblFileSize;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@property PMNetworkManager *networkManager;

@property BOOL isDownloaded;
@property NSString *filepath;
@property NSURL *filepathUrl;
@end

@implementation PMFilePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self setTitle:self.file[@"filename"]];
    
    self.lblFileName.text = self.file[@"filename"];
    self.lblFileSize.text = [PMFileManager FileSizeAsString:[self.file[@"size"] longLongValue]];
    
    
    [self performSelector:@selector(downloadFile) withObject:nil afterDelay:.1];
    //[self downloadFile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)downloadFile
{
    [AlertManager showProgressBarWithTitle:nil view:self.navigationController.view];
    
    NSURLSessionDownloadTask *downloadTask = [[PMAPIManager shared] downloadFileWithAccount:[PMAPIManager shared].namespaceId file:self.file completion:^(NSURLResponse *responseData, NSURL *filepath, NSError *error) {
        
        [AlertManager hideProgressBar];
        self.progressView.hidden = YES;
        
        if(!error)
        {
            NSData *data = [NSData dataWithContentsOfURL:filepath];
            
            NSString *iconFile = [PMFileManager IconFileByExt:[self.file[@"filename"] pathExtension]];
            UIImage *image = [UIImage imageNamed:iconFile];
            
            
            NSString *mimeType = self.file[@"content_type"];
            if([mimeType isEqualToString:@"image/jpeg"] || [mimeType isEqualToString:@"image/png"])
            {
                UIImage *tmpImage = [UIImage imageWithData:data];
                
                if(tmpImage) image = tmpImage;
            }
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            
            CGRect imageViewFrame = imageView.frame;
            CGRect scrollViewFrame = self.scrollView.frame;
            
            if(imageViewFrame.size.width > scrollViewFrame.size.width || imageViewFrame.size.height > scrollViewFrame.size.height)
                [imageView setFrame:CGRectMake(0, 0, scrollViewFrame.size.width, scrollViewFrame.size.height)];
            else
                [imageView setFrame:CGRectMake(0, 0, imageViewFrame.size.width, imageViewFrame.size.height)];
            
            CGFloat scrollViewCenterX = CGRectGetMidX(_scrollView.bounds);
            CGFloat scrollViewCenterY = CGRectGetMidY(_scrollView.bounds) + _scrollView.contentInset.top / 2 ;
            imageView.center = CGPointMake(scrollViewCenterX, scrollViewCenterY);
            
            [self.scrollView setContentSize:imageView.frame.size];
            [self.scrollView addSubview:imageView];
            
            self.isDownloaded = YES;
            self.filepath = filepath.path;
            self.filepathUrl = filepath;
        }
    }];
    
    [self.progressView setProgressWithDownloadProgressOfTask:downloadTask animated:YES];
    [downloadTask resume];

}
- (IBAction)btnAttachClicked:(id)sender {
    PMMailComposeVC *mailComposeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
    
    NSMutableArray *files = [[NSMutableArray alloc] init];
    [files addObject:self.filepath];
    mailComposeVC.files = files;
    
    [self presentViewController:mailComposeVC animated:YES completion:nil];
}
- (IBAction)btnUploadFileClicked:(id)sender {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Choose your cloud to save file"
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionDropbox = [UIAlertAction
                         actionWithTitle:@"Dropbox"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [self onUploadFileToDropbox];
                         }];
    
    UIAlertAction *actionBox = [UIAlertAction
                                    actionWithTitle:@"Box"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                        [self onUploadFileToBox];
                                    }];
    
    UIAlertAction *actionGoogleDrive = [UIAlertAction
                                    actionWithTitle:@"GoogleDrive"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                        [self onUploadFileToGoogleDrive];
                                    }];
    
    UIAlertAction *actionOneDrive = [UIAlertAction
                                    actionWithTitle:@"OneDrive"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                        [self onUploadFileToOneDrive];
                                    }];
    
    UIAlertAction *actionCancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:actionDropbox];
    [alert addAction:actionBox];
    [alert addAction:actionGoogleDrive];
    [alert addAction:actionOneDrive];
    [alert addAction:actionCancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

// ================== Upload to Dropbox ================
-(void) onUploadFileToDropbox
{
    if (![[DBSession sharedSession] isLinked]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLoginDone) name:@"OPEN_DROPBOX_VIEW" object:nil];
        [[DBSession sharedSession] linkFromController:self];
    }
    else
    {
        [self uploadFileToDropBox];
    }
}

-(void)dropboxLoginDone
{
    [self uploadFileToDropBox];
}
-(void)uploadFileToDropBox
{
    [AlertManager showProgressBarWithTitle:@UPLOADING view:self.navigationController.view];
    
    if (dropboxClient == nil) {
        dropboxClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        dropboxClient.delegate = self;
    }
    [dropboxClient uploadFile:self.file[@"filename"] toPath:@"/" withParentRev:@"" fromPath:self.filepath];
}
-(void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath
{
    [AlertManager hideProgressBar];
    [AlertManager showAlertWithTitle:@"Info" message:@"The file was uploaded to your Dropbox successfully!" controller:self];
}
-(void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
    [AlertManager hideProgressBar];
    NSLog(@"Dropbox file upload error: %@", error);
    [AlertManager showAlertWithTitle:@"Error" message:@"File upload was failed" controller:self];
}

// =================== Upload to Box ========================
-(void)onUploadFileToBox
{
    NSArray *users = [BOXContentClient users];
    
    
    if(users.count > 0)
    {
        BOXUser *user = [users objectAtIndex:0];
        boxClient = [BOXContentClient clientForUser:user];
        
        [self uploadFileToBox];
    }
    else
    {
        // Create a new client for the account we want to add.
        BOXContentClient *client = [BOXContentClient clientForNewSession];
        
        [client authenticateWithCompletionBlock:^(BOXUser *user, NSError *error) {
            if (error) {
                if ([error.domain isEqualToString:BOXContentSDKErrorDomain] && error.code == BOXContentSDKAPIUserCancelledError) {
                    BOXLog(@"Authentication was cancelled, please try again.");
                } else {
                    [AlertManager showAlertWithTitle:@"Error" message:@"Login failed, please try again." controller:self];
                }
            } else {
                boxClient = [BOXContentClient clientForUser:user];
                
                [self uploadFileToBox];
            }
        }];
    }
}
-(void)uploadFileToBox
{
    [AlertManager showProgressBarWithTitle:@UPLOADING view:self.navigationController.view];
    BOXFileUploadRequest *uploadRequest = [boxClient fileUploadRequestToFolderWithID:BOXAPIFolderIDRoot fromLocalFilePath:self.filepath];
    
    // Optional: By default the name of the file on the local filesystem will be used as the name on Box. However, you can
    // set a different name for the file by configuring the request:
    uploadRequest.fileName = self.file[@"filename"];
    
    [uploadRequest performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
        // Update a progress bar, etc.
    } completion:^(BOXFile *file, NSError *error) {
        // Upload has completed. If successful, file will be non-nil; otherwise, error will be non-nil.
        
        [AlertManager hideProgressBar];
        
        if(!error)
        {
            [AlertManager showAlertWithTitle:@"Info" message:@"The file was uploaded to your Box successfully!" controller:self];
        }
        else
        {
            NSLog(@"Box file upload error: %@", error);
            [AlertManager showAlertWithTitle:@"Error" message:@"File upload was failed" controller:self];
        }
    }];
}

// ====================================== Upload to GoogleDrive =================================
-(void)onUploadFileToGoogleDrive
{
    gtlService = [[GTLServiceDrive alloc] init];
    gtlService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:@GOOGLE_KEYCHAIN_ITEM_NAME
                                                                                  clientID:@GOOGLE_CLIENT_ID
                                                                              clientSecret:@GOOGLE_CLIENT_SECRET];
    
    
    if (!gtlService.authorizer.canAuthorize) {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        SEL finishedSelector = @selector(viewController:finishedWithAuthToGoogleDrive:error:);
        GTMOAuth2ViewControllerTouch *authViewController =
        [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
                                                   clientID:@GOOGLE_CLIENT_ID
                                               clientSecret:@GOOGLE_CLIENT_SECRET
                                           keychainItemName:@GOOGLE_KEYCHAIN_ITEM_NAME
                                                   delegate:self
                                           finishedSelector:finishedSelector];
        
        [self.navigationController pushViewController:authViewController animated:YES];
    } else {
        [self uploadFileToGoogleDrive];
    }
}

-(void)uploadFileToGoogleDrive
{
    [AlertManager showProgressBarWithTitle:@UPLOADING view:self.navigationController.view];
    
    
    
    GTLDriveFile *driveFile = [GTLDriveFile object];
    driveFile.title = self.file[@"filename"];
    
    NSData *data = [NSData dataWithContentsOfFile:self.filepath];
    
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data MIMEType:self.file[@"content_type"]];

    
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:driveFile
                                            uploadParameters:uploadParameters];
    
    
    [gtlService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                              GTLDriveFile *updatedFile,
                                                              NSError *error) {
        [AlertManager hideProgressBar];
        
        if (error == nil) {
            [AlertManager showAlertWithTitle:@"Info" message:@"The file was uploaded to your GoogleDrive successfully!" controller:self];
        } else {
            NSLog(@"GoogleDrive file upload error: %@", error);
            [AlertManager showAlertWithTitle:@"Error" message:@"File upload was failed" controller:self];
        }
    }];
}
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
                                    finishedWithAuthToGoogleDrive:(GTMOAuth2Authentication *)auth
                                    error:(NSError *)error {
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    if (error == nil) {
        [self isAuthorizedWithAuthentication:auth];
        
        
        [self uploadFileToGoogleDrive];
    }
}
- (GTLServiceDrive *)gtlDriveService {
    static GTLServiceDrive *service = nil;
    
    if (!service) {
        service = [[GTLServiceDrive alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    }
    return service;
}
- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth {
    [[self gtlDriveService] setAuthorizer:auth];
}

// ====================== Upload to OneDrive =======================
-(void)onUploadFileToOneDrive
{
    //ODClient *client = [ODClient loadCurrentClient];
    
    NSDate *now = [NSDate date];
    NSDate *lastLoginTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"OneDriveLoginTime"];
    if([now timeIntervalSinceDate:lastLoginTime] > 3600)
    {
        [ODClient authenticatedClientWithCompletion:^(ODClient *client, NSError *error){
            if (!error){
                onedriveClient = client;
                [ODClient setCurrentClient:client];
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self uploadFileToOneDrive];
                });
                
                NSDate *now = [NSDate date];
                [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"OneDriveLoginTime"];
            }
            else{
                NSLog(@"OneDrive Authentication canceled!");
                
            }
        }];
    }
    else
    {
        [ODClient clientWithCompletion:^(ODClient *client, NSError *error){
            if (!error){
                onedriveClient = client;
                [ODClient setCurrentClient:client];
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self uploadFileToOneDrive];
                });
                
                NSDate *now = [NSDate date];
                [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"OneDriveLoginTime"];
            }
            else{
                NSLog(@"OneDrive Authentication canceled!");
                
            }
        }];
    }
}

-(void)uploadFileToOneDrive
{
    [AlertManager showProgressBarWithTitle:@UPLOADING view:self.navigationController.view];
    
    ODItemContentRequest *contentRequest = [[[[onedriveClient drive] items:@"root"] itemByPath:self.file[@"filename"]] contentRequest];
    [contentRequest uploadFromFile:self.filepathUrl completion:^(ODItem *item, NSError *error){
        // Returns the item that was just uploaded.
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [AlertManager hideProgressBar];
            
            if (error == nil) {
                [AlertManager showAlertWithTitle:@"Info" message:@"The file was uploaded to your OneDrive successfully!" controller:self];
            } else {
                NSLog(@"OneDrive file upload error: %@", error);
                [AlertManager showAlertWithTitle:@"Error" message:@"File upload was failed" controller:self];
                [ODClient setCurrentClient:nil];
                
            }
        });
        
        
    }];
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
