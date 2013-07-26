#import "PXRViewController.h"

@implementation PXRViewController

- (void)viewDidLoad{
    [super viewDidLoad];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *localFile = [documentsDirectory stringByAppendingPathComponent:@"download.zip"];
	NSURL *localURL = [[NSURL alloc] initFileURLWithPath:localFile];
	
	NSURL *remoteURL = [[NSURL alloc] initWithString:REMOTE_FILE_PATH];
	
	_cd = [PXRContentDownloader contentDownloaderWithRemoteURL:remoteURL andLocalURL:localURL];
	_cd.delegate = self;
}


- (IBAction)startDownload:(id)sender{
	if(_cd.needsToResume){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Existing download" message:@"There is a download already in progress do you want to pick up where you left off?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
		[alert show];
	}else{
		[_cd startDownload];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	switch (buttonIndex) {
		case 1:
			[_cd clearDownload];
			[_cd startDownload];
			break;
		default:
			[_cd startDownload];
			break;
	}
}

- (IBAction)cancelDownload:(id)sender{
	[_cd cancelDownload];
}

- (IBAction)clearDownload:(id)sender{
	self.progressView.progress = 0.0f;
	[_cd clearDownload];
}

- (void)contentDownloader:(PXRContentDownloader *)cdl completedDownloadWithURL:(NSURL *)localURL{
	NSLog(@"done %@", localURL);
}

- (void)contentDownloaderDownloadStart:(PXRContentDownloader *)cdl{
	self.progressView.progress = 0.0f;
}

- (void)contentDownloader:(PXRContentDownloader *)cdl onDownloadError:(NSError *)error{
	NSLog(@"error");
}

- (void)contentDownloader:(PXRContentDownloader *)cdl onDownloadProgress:(float)progress{
	self.progressView.progress = progress;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
