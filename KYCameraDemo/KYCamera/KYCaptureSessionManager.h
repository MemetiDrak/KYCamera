//
//  KYCaptureSessionManager.h
//  xhbn
//
//  Created by mc814 on 15/6/30.
//  Copyright (c) 2015年 KangYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

@interface KYCaptureSessionManager : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic) CGImageRef currentImage;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDeviceInput *inputDevice;
@property (strong, nonatomic) AVCaptureVideoDataOutput *videoOutput;
@property (strong, nonatomic) CALayer *previewLayer;
@property (strong, nonatomic) AVCaptureDevice *frontCamera;
@property (strong, nonatomic) AVCaptureDevice *backCamera;

@property (strong, nonatomic) CIContext *imageContext;
@property (copy, nonatomic) CIFilter *userFilter;

- (void)configureWithView:(UIView *)view previewRect:(CGRect)preivewRect;

- (void)takePhoto:(void (^)(UIImage *image))block;
- (void)switchCamera;
- (void)focusInPoint:(CGPoint)point;
- (void)switchFlashMode;
- (NSString *)currentFlashMode;

- (void)startRunning;
- (void)stopRunning;

@end
