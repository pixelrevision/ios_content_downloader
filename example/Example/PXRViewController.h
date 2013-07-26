#import <UIKit/UIKit.h>
#import "PXRContentDownloader.h"

@interface PXRViewController : UIViewController <PXRContentDownloaderDelegate, UIAlertViewDelegate>{
	PXRContentDownloader *_cd;
}

#define REMOTE_FILE_PATH @"http://download.thinkbroadband.com/20MB.zip"

@property (weak) IBOutlet UIProgressView *progressView;

- (IBAction)startDownload:(id)sender;
- (IBAction)cancelDownload:(id)sender;
- (IBAction)clearDownload:(id)sender;

@end
