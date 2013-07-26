------------------------------------------------------------------------------
        __                __                      __         __               
.-----.|__|.--.--..-----.|  |.----..-----..--.--.|__|.-----.|__|.-----..-----.
|  _  ||  ||_   _||  -__||  ||   _||  -__||  |  ||  ||__ --||  ||  _  ||     |
|   __||__||__.__||_____||__||__|  |_____| \___/ |__||_____||__||_____||__|__|
|__|                                                                          
------------------------------------------------------------------------------


******************************************************************************
Content Downloader
******************************************************************************

What is it?
An class that holds an NSURLCOnnection and is able to check for a newer date in in file as well as resume a cancelled download.

Setup:
1. Drag the contents of the "source" folder into your project and check "copy items into destination group's folder".
2. Import "PXRContentDownloader.h"

Usage:
The delegate callbacks are:
- (void)contentDownloaderDownloadStart:(PXRContentDownloader *)cdl;
- (void)contentDownloader:(PXRContentDownloader *)cdl onDownloadProgress:(float)progress;
- (void)contentDownloader:(PXRContentDownloader *)cdl onDownloadError:(NSError *)error;
- (void)contentDownloader:(PXRContentDownloader *)cdl completedDownloadWithURL:(NSURL *)localURL;

******************************************************************************
License - MIT
******************************************************************************

Copyright (c) 2013 pixelrevision

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
