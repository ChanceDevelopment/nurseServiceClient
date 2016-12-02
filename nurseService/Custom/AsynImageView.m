#import "AsynImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation AsynImageView

@synthesize imageURL = _imageURL;
@synthesize placeholderImage = _placeholderImage;

@synthesize fileName = _fileName;
@synthesize canDownload;
@synthesize bigImageURL;
@synthesize downloadDateline;
@synthesize tagString;
@synthesize imageTag;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.layer.borderWidth = 2.0;
        self.backgroundColor = [UIColor grayColor];
        self.canDownload = YES;
        
    }
    return self;
}

-(id)init
{
    if (self = [super init]) {
        canDownload = YES;
    }
    return self;
}

-(id)initWithTag:(NSInteger)tag
{
    self = [super init];
    if (self) {
        // Initialization code
        self.tag = tag;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.layer.borderWidth = 2.0;
        self.backgroundColor = [UIColor grayColor];
        
    }
    return self;
}

//重写placeholderImage的Setter方法
-(void)setPlaceholderImage:(UIImage *)placeholderImage
{
    canDownload = YES;
    if(placeholderImage != _placeholderImage )
    {
        _placeholderImage = placeholderImage;
        self.image = _placeholderImage;    //指定默认图片
    }
}

//重写imageURL的Setter方法
-(void)setImageURL:(NSString *)imageURL
{
    //    UIViewContentModeScaleToFill,
    //    UIViewContentModeScaleAspectFit,      // contents scaled to fit with fixed aspect. remainder is transparent
    //    UIViewContentModeScaleAspectFill,
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.borderWidth = 0;
    self.layer.masksToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    self.backgroundColor = [UIColor whiteColor];
    if(imageURL != _imageURL)
    {
        self.image = _placeholderImage;
//        self.image = [[UIImage alloc] initWithData:UIImagePNGRepresentation(_placeholderImage)];    //指定默认图片
        _imageURL = imageURL;
        self.imageURL = imageURL;
    }
    
    if(self.imageURL && canDownload)
    {
        //确定图片的缓存地址
        NSString *libraryfolderPath = [NSHomeDirectory() stringByAppendingString:@"/Library"];
        NSString *myPath=[libraryfolderPath stringByAppendingPathComponent:ALBUMNAME];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:myPath]) {
            [fm createDirectoryAtPath:myPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *tmpPath = [myPath stringByAppendingPathComponent:@"AsynImage"];
        
        if(![fm fileExistsAtPath:tmpPath])
        {
            [fm createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSArray *lineArray = [self.imageURL componentsSeparatedByString:@"/"];
        NSMutableString *tempfilename = [[NSMutableString alloc] initWithCapacity:0];
        for (NSInteger i = [lineArray count] - 1; i >= [lineArray count] - 3 && i >= 0; i--) {
            NSString *str = [lineArray objectAtIndex:i];
            [tempfilename insertString:str atIndex:0];
        }
        self.fileName = [NSString stringWithFormat:@"%@/%@",tmpPath,tempfilename];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:_fileName])
        {
            //下载图片，保存到本地缓存中
            Reachability *reach = [Reachability reachabilityForInternetConnection];
            switch ([reach currentReachabilityStatus]) {
                case NotReachable:
                {
                    break;
                }
                case ReachableViaWWAN:
                {
                    [self loadImage];
                    break;
                }
                case ReachableViaWiFi:
                {
                    [self loadImage];
                    break;
                }
            }
        }
        else
        {
            //本地缓存中已经存在，直接指定请求的网络图片
            self.image = [UIImage imageWithContentsOfFile:_fileName];
            //            if (self.tag == -10) {
            //                CGSize imagesize = self.image.size;
            //                if (self.image == nil) {
            //                    imagesize = CGSizeMake(100.0, 260.0);
            //                }
            //                CGFloat scale = imagesize.width/imagesize.height;
            //                if (scale < 0.1) {
            //                    scale = 10.0/13.0;
            //                }
            //                CGFloat hight = 260;
            //                CGFloat width = hight * scale;
            //                CGSize newsize = CGSizeMake(width, hight);
            //                UIImage *suoImage = [self thumbnailWithImageWithoutScale:self.image size:newsize];
            //                CGRect framge = CGRectMake(0, 0, width, hight);
            //                self.image = [self imageFromImage:suoImage inRect:framge];
            //
            //                CGRect originalFrame = self.frame;
            //                originalFrame.size.width = width/2.0;
            //                self.frame = originalFrame;
            //
            //            }
            //            else if (self.tag == -9){
            //                CGSize newsize = CGSizeMake(self.bounds.size.width * 2, self.bounds.size.height * 2);
            //                self.image = [self imageFromImage:self.image inRect:CGRectMake(0, 0, newsize.width, newsize.height)];
            //            }
        }
    }
}




//网络请求图片，缓存到本地沙河中
-(void)loadImage
{
    //对路径进行编码
    @try {
        //请求图片的下载路径
        //定义一个缓存cache
        NSURLCache *urlCache = [NSURLCache sharedURLCache];
        /*设置缓存大小为1M*/
        [urlCache setMemoryCapacity:1*124*1024];
        
        //设子请求超时时间为30s
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.imageURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
        
        //从请求中获取缓存输出
        NSCachedURLResponse *response = [urlCache cachedResponseForRequest:request];
        if(response != nil)
        {
            [request setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
        }
        if ([self.imageURL hasSuffix:@"-1-1-1"]) {
            NSString *str = [self.imageURL substringToIndex:[self.imageURL length] - 6];
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:str] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
            
            //从请求中获取缓存输出
            //            NSCachedURLResponse *response = [urlCache cachedResponseForRequest:request];
            
        }
        /*创建NSURLConnection*/
        if(!connection)
            connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        //开启一个runloop，使它始终处于运行状态
        
        UIApplication *app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        
    }
    @catch (NSException *exception) {
        //        NSLog(@"没有相关资源或者网络异常");
    }
    @finally {
        ;//.....
    }
}

#pragma mark - NSURLConnection Delegate Methods
//请求成功，且接收数据(每接收一次调用一次函数)
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(loadData==nil)
    {
        loadData=[[NSMutableData alloc] initWithCapacity:2048];
    }
    [loadData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
    //    NSLog(@"将缓存输出");
}

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    //    NSLog(@"即将发送请求");
    return request;
}
//下载完成，将文件保存到沙河里面
-(void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    
    if ([self.imageURL hasSuffix:@"-1-1-1"]) {
        self.imageURL = [self.imageURL substringToIndex:[self.imageURL length] - 6];
    }
    
    NSString *imageStr = [[NSString alloc] initWithData:loadData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",imageStr);
    
    if (imageStr != nil) {
        @try {
            NSRange rang1=[imageStr rangeOfString:@"<title>"];
            NSMutableString *imageStr2=[[NSMutableString alloc]initWithString:[imageStr substringFromIndex:rang1.location+rang1.length]];
            
            NSRange rang2=[imageStr2 rangeOfString:@"</title>"];
            NSMutableString *errorString = [[NSMutableString alloc]initWithString:[imageStr2 substringToIndex:rang2.location]];
            if ([errorString rangeOfString:@"404"].length == 0 || [errorString rangeOfString:@"403"].length == 0) {
                UIApplication *app = [UIApplication sharedApplication];
                app.networkActivityIndicatorVisible = NO;
                
                //如果发生错误，则重新加载
                connection = nil;
                loadData = nil;
                self.canDownload = NO;
//                self.image = [[UIImage alloc] initWithData:UIImagePNGRepresentation(_placeholderImage)];
                
                return;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception = %@",exception);
        }
        @finally {
            
        }
    }
    
    
    if([loadData writeToFile:_fileName atomically:YES])
    {
        
        self.image = [UIImage imageWithContentsOfFile:_fileName];
        if (self.tag == -10) {
            CGSize imagesize = self.image.size;
            if (self.image == nil) {
                CGSizeMake(100.0, 260.0);
            }
            CGFloat scale = imagesize.width/imagesize.height;
            if (scale < 0.1) {
                scale = 10.0/13.0;
            }
            if (scale > 1000000000000000) {
                scale = 10.0/13.0;
            }
            CGFloat hight = 260;
            CGFloat width = hight * scale;
            CGSize newsize = CGSizeMake(width, hight);
            UIImage *suoImage = [self thumbnailWithImageWithoutScale:self.image size:newsize];
            CGRect framge = CGRectMake(0, 0, width, hight);
            self.image = [self imageFromImage:suoImage inRect:framge];
            
            CGRect originalFrame = self.frame;
            originalFrame.size.width = width/2.0;
            self.frame = originalFrame;
            self.tag = 1;
        }
        else if (self.tag == -9){
            CGSize newsize = CGSizeMake(self.bounds.size.width * 2, self.bounds.size.height * 2);
            self.image = [self thumbnailWithImage:self.image size:newsize];
            self.tag = 1;
        }
    }
    else{
        NSLog(@"写入图片失败");
    }
    connection = nil;
    loadData = nil;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    NSLog(@"%@",timeString);
    //    self.canDownload = NO;
}


- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}

- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize

{
    
    UIImage *newimage;
    
    if (nil == image) {
        
        newimage = nil;
        
    }
    
    else{
        
        UIGraphicsBeginImageContext(asize);
        
        [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
        
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
    }
    
    return newimage;
    
}

/*******按照自己的比例生成********/
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize

{
    UIImage *newimage;
    
    if (nil == image) {
        
        newimage = nil;
        
    }
    
    else{
        
        CGSize oldsize = image.size;
        
        CGRect rect;
        
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            
            rect.size.height = asize.height;
            
            rect.origin.x = (asize.width - rect.size.width)/2;
            
            rect.origin.y = 0;
            
        }
        
        else{
            
            rect.size.width = asize.width;
            
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            
            rect.origin.x = 0;
            
            rect.origin.y = (asize.height - rect.size.height)/2;
            
        }
        
        UIGraphicsBeginImageContext(asize);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        
        [image drawInRect:rect];
        
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
    }
    
    return newimage;
    
}


//网络连接错误或者请求成功但是加载数据异常
-(void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    
    //如果发生错误，则重新加载
    connection = nil;
    loadData = nil;
    self.imageURL = nil;
    
    //    [self loadImage];
}




//-(void)dealloc
//{
//
//    [_fileName release];
//    [loadData release];
//    [connection release];
//
//    [_placeholderImage release];
//    [_imageURL release];
//
//    [super dealloc];
//}

@end