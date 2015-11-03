//
//  PMDropboxFileViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMDropboxFileViewController.h"
@interface PMDropboxFileViewController ()
{
    
}
@end

@implementation PMDropboxFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lblFileName.text = self.fileitem.filename;
    self.lblFileSize.text = self.fileitem.humanReadableSize;
    
    _restClient.delegate = self;
    
    [self performSelector:@selector(downloadFile:) withObject:self.fileitem.path afterDelay:.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)downloadFile:(NSString *)filePath
{
    [AlertManager showProgressBarWithTitle:nil view:self.navigationController.view];
    [self.restClient loadFile:filePath intoPath:[[PMFileManager DownloadDirectory:@"Dropbox"] stringByAppendingPathComponent:[filePath lastPathComponent]]];
}

-(void)restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath
{
    self.progressView.progress = progress;
}
- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath
{
    [AlertManager hideProgressBar];
    self.progressView.hidden = YES;
    
    [self showPreviewFile:destPath];
    
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    [AlertManager hideProgressBar];
    self.progressView.hidden = YES;
    [AlertManager showAlertWithTitle:@"Error" message:@"File download was failed" controller:self];
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
