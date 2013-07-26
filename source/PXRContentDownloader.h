#import <Foundation/Foundation.h>

#define PXRContentDownloaderModDate @"package-downloader-modification-date"

@class PXRContentDownloader;

/**
 Delegate responsible for handling loading events.
 */
@protocol PXRContentDownloaderDelegate <NSObject>
@optional
/**
 Called when the downloader starts loading from a URL.
 @param cdl The content downloader.
 */
- (void)contentDownloaderDownloadStart:(PXRContentDownloader *)cdl;
/**
 Called as download progress is made.
  @param cdl The content downloader.
  @param progress The progress of the download 0.0 - 1.0.
 */
- (void)contentDownloader:(PXRContentDownloader *)cdl onDownloadProgress:(float)progress;
/**
 Called if there is an error loading.
  @param cdl The content downloader.
  @param error The error while loading.
 */
- (void)contentDownloader:(PXRContentDownloader *)cdl onDownloadError:(NSError *)error;
/**
 Called when the download is complete.
 @param cdl The content downloader.
 @param localURL The path to the downloaded file.
 */
- (void)contentDownloader:(PXRContentDownloader *)cdl completedDownloadWithURL:(NSURL *)localURL;
@end

/**
 A class setup to load a url to a local file, check it's date and resume downloading if needed.
 */
@interface PXRContentDownloader : NSObject <NSURLConnectionDelegate, NSCoding>{
	NSFileHandle *_fileHandle;
	NSURLConnection *_URLConnection;
	long long _expectedDownloadSize;
	long long _bytesDownloaded;
}

/**
 The downloader's delegate
 */
@property (weak) NSObject <PXRContentDownloaderDelegate> *delegate;
/**
 If the downloader should check the modification date of the file on the server before downloading.
 */
@property BOOL checkDateBeforeDownload;
/**
 The remote URL of the file.
 */
@property NSURL *remoteURL;
/**
 The local URL where the file will be saved.
 */
@property NSURL *localURL;
/**
 The last modification date of the file.  Can save/set this if needed when application goes to background or is quit as needed.
 */
@property NSDate *lastModifiedDate;
/**
 Used to see if the downloader needs to resume a download.  Useful for prompting the user.
 */
@property (nonatomic, readonly) BOOL needsToResume;
/**
 The expected size of the download as reported by the server in bytes.
 */
@property (readonly) long long expectedDownloadSize;
/**
 The amount of bytes downloaded.
 */
@property (readonly) long long bytesDownloaded;

/**
 Create a downloader with a remote and local url.
 @param remoteURL The remote url to load the content from.
 @param localURL The path to save the file to.
 */
+ (PXRContentDownloader*)contentDownloaderWithRemoteURL:(NSURL *)remoteURL andLocalURL:(NSURL *)localURL;
/**
 Starts downloading.
 */
- (void)startDownload;
/**
 Cancels a download.
 */
- (void)cancelDownload;
/**
 Cancels a download and clears any current data downloaded as well as the date modified.
 */
- (void)clearDownload;

@end
