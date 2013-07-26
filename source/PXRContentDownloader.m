

#import "PXRContentDownloader.h"

@implementation PXRContentDownloader

- (id)init{
	self = [super init];
	self.checkDateBeforeDownload = YES;
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
	NSKeyedUnarchiver *a = (NSKeyedUnarchiver *)aDecoder;
	self = [super init];
	self.checkDateBeforeDownload = [a decodeBoolForKey:@"checkDateBeforeDownload"];
	self.remoteURL = [a decodeObjectForKey:@"remoteURL"];
	self.localURL = [a decodeObjectForKey:@"localURL"];
	self.lastModifiedDate = [a decodeObjectForKey:@"lastModifiedDate"];
	_expectedDownloadSize = [[a decodeObjectForKey:@"expectedDownloadSize"] longLongValue];
	_bytesDownloaded = [[a decodeObjectForKey:@"bytesDownloaded"] longLongValue];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
	[self cleanupCurrentDownload];
	NSKeyedArchiver *a = (NSKeyedArchiver *)aCoder;
	[a encodeBool:self.checkDateBeforeDownload forKey:@"checkDateBeforeDownload"];
	[a encodeObject:self.remoteURL forKey:@"remoteURL"];
	[a encodeObject:self.localURL forKey:@"localURL"];
	[a encodeObject:self.lastModifiedDate forKey:@"lastModifiedDate"];
	[a encodeObject:[NSNumber numberWithLongLong:_expectedDownloadSize] forKey:@"expectedDownloadSize"];
	[a encodeObject:[NSNumber numberWithLongLong:_bytesDownloaded] forKey:@"bytesDownloaded"];
}

+ (PXRContentDownloader*)contentDownloaderWithRemoteURL:(NSURL *)remoteURL andLocalURL:(NSURL *)localURL{
	PXRContentDownloader *pd = [[PXRContentDownloader alloc] init];
	pd.remoteURL = remoteURL;
	pd.localURL = localURL;
	return pd;
}

- (void)startDownload{
	[self cleanupCurrentDownload];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.remoteURL];
	// check to see if we need to resume the download
	if(_bytesDownloaded > 0 && _expectedDownloadSize > 0){
		if(_bytesDownloaded == _expectedDownloadSize){
			_bytesDownloaded = 0;
			_expectedDownloadSize = 0;
		}else{
			NSString *range = [NSString stringWithFormat:@"bytes=%llu-", _bytesDownloaded];
			[request setValue:range forHTTPHeaderField:@"Range"];
		}
	}
	_URLConnection = [NSURLConnection connectionWithRequest:request delegate:self];
	[_URLConnection start];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data{
	[_fileHandle writeData:data];
	[_fileHandle synchronizeFile];
	
	_bytesDownloaded += [data length];
	
	if(self.delegate) {
		float progress = ((float)_bytesDownloaded/(float)_expectedDownloadSize);
		if(progress > 1.0f){
			progress = 0.0f;
		}
		if([self.delegate respondsToSelector:@selector(contentDownloader:onDownloadProgress:)]){
			[self.delegate contentDownloader:self onDownloadProgress:progress];
		}
	}
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse *)response {
	int statusCode = [response statusCode];
	
	NSDate *modified;
	NSDictionary *headers = [response allHeaderFields];
	NSString *modifiedString = [headers objectForKey:@"Last-Modified"];
	if(modifiedString){
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
		df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
		modified = [df dateFromString: modifiedString];
	}
	
	// check if we can actually resume if needed
	if(statusCode != 206 && _bytesDownloaded > 0){
		// can't resume try again
		_bytesDownloaded = 0;
		NSLog(@"could not resume.  starting over");
		[self startDownload];
		return;
	}
	BOOL continueDownload = NO;
	
	// check if we need to resume a download
	if(_bytesDownloaded > 0){
		long long bytesToDownload = [response expectedContentLength];
		int expectedPart = _expectedDownloadSize - _bytesDownloaded;
		if(expectedPart == bytesToDownload){
			continueDownload = YES;
			NSLog(@"file already exists resume download");
		}else{
			_bytesDownloaded = 0;
			[self startDownload];
			NSLog(@"file size has changed on the server or is reported incorrectly, starting over");
			return;
		}
	}
	
	// no modification date create the file handle and continue
	if(!self.lastModifiedDate){
		continueDownload = YES;
		NSLog(@"no modified date resume download");
	}
	
	// check if the modification is newer
	NSTimeInterval newer = [modified timeIntervalSinceDate:self.lastModifiedDate];
	if(newer > 0){
		continueDownload = YES;
		NSLog(@"server date is newer download");
	}
	
	// finally if we have checkDateBeforeDownload off then force the download
	if(!self.checkDateBeforeDownload){
		continueDownload = YES;
		NSLog(@"not checking date download");
	}
	
	// if there is no download kill
	if(!continueDownload){
		NSLog(@"download does not need to proceed aborting");
		[self cleanupCurrentDownload];
		return;
	}
	
	// hold onto the date for later if it's avaialable
	if(modified){
		self.lastModifiedDate = modified;
	}
	
	// add the expected download size
	if(statusCode == 200) {
		_expectedDownloadSize = [response expectedContentLength];
	}
	
	[self createFileHandle];
}

- (void)createFileHandle{
	NSFileManager * fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	if([fileManager fileExistsAtPath:self.localURL.path] && _bytesDownloaded == 0) {
		[fileManager removeItemAtPath:self.localURL.path error:&error];
		if(error){
			NSLog(@"something went wrong trying to delete the existing file");
		}
	}
	
	if(_bytesDownloaded == 0){
		// create a new file if needed
		[fileManager createFileAtPath:self.localURL.path contents:nil attributes:nil];
	}
	
	_fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.localURL.path];
	[_fileHandle seekToFileOffset:_bytesDownloaded];
	
	if(self.delegate){
		if([self.delegate respondsToSelector:@selector(contentDownloaderDownloadStart:)]){
			[self.delegate contentDownloaderDownloadStart:self];
		}
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	if(self.delegate) {
		if([self.delegate respondsToSelector:@selector(contentDownloader:completedDownloadWithURL:)]){
			[self.delegate contentDownloader:self completedDownloadWithURL:self.localURL];
		}
	}
	
	[self cleanupCurrentDownload];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error{
	if(self.delegate){
		if([self.delegate respondsToSelector:@selector(contentDownloader:onDownloadError:)]){
			[self.delegate contentDownloader:self onDownloadError:error];
		}
	}
	[self cleanupCurrentDownload];
}

- (void)cancelDownload{
	[self cleanupCurrentDownload];
}

- (void)cleanupCurrentDownload{
	if(_URLConnection){
		[_URLConnection cancel];
		_URLConnection = nil;
	}
	if(_fileHandle){
		[_fileHandle closeFile];
		_fileHandle = nil;
	}
}

- (BOOL)needsToResume{
	return _expectedDownloadSize > 0 && _bytesDownloaded > 0 && _expectedDownloadSize != _bytesDownloaded;
}

- (void)clearDownload{
	[self cleanupCurrentDownload];
	_expectedDownloadSize = 0;
	_bytesDownloaded = 0;
	self.lastModifiedDate = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	if([fileManager fileExistsAtPath:self.localURL.path]){
		[fileManager removeItemAtPath:self.localURL.path error:&error];
		if(error){
			NSLog(@"something went wrong trying to delete the existing file");
		}
	}
}

- (void)dealloc{
	[self cleanupCurrentDownload];
}

@end
