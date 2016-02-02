//
//  KYCaptureSessionManager.m
//  xhbn
//
//  Created by mc814 on 15/6/30.
//  Copyright (c) 2015年 KangYang. All rights reserved.
//

#import "KYCaptureSessionManager.h"

@implementation KYCaptureSessionManager

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("com.kangyang.camera.session", DISPATCH_QUEUE_SERIAL);
    self.sessionQueue = sessionQueue;
    
    self.frontCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
    self.backCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
    
    self.inputDevice = [[AVCaptureDeviceInput alloc] initWithDevice:self.backCamera error:nil];
    
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    self.videoOutput.alwaysDiscardsLateVideoFrames = YES;
    [self.videoOutput setSampleBufferDelegate:self queue:self.sessionQueue];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession beginConfiguration];
    self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    if ([self.captureSession canAddInput:self.inputDevice]) {
        [self.captureSession addInput:self.inputDevice];
    }
    if ([self.captureSession canAddOutput:self.videoOutput]) {
        [self.captureSession addOutput:self.videoOutput];
    }
    
    [self.captureSession commitConfiguration];
    
    self.previewLayer = [CALayer layer];
    self.previewLayer.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
//    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
//    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    return self;
}

- (void)dealloc
{
    [self.captureSession stopRunning];
    self.previewLayer = nil;
    self.captureSession = nil;
    self.videoOutput = nil;
    self.inputDevice = nil;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *result = [CIImage imageWithCVImageBuffer:imageBuffer];
        
        if (self.userFilter) {
            
            [self.userFilter setValue:result forKey:kCIInputImageKey];
            result = [self.userFilter outputImage];
        }
        
        CGImageRef finishedImage = [self.imageContext createCGImage:result fromRect:result.extent];
        self.currentImage = finishedImage;
        
        [self.previewLayer performSelectorOnMainThread:@selector(setContents:)
                                            withObject:(__bridge id)finishedImage
                                         waitUntilDone:YES];
        
        CGImageRelease(finishedImage);
    }
}

#pragma mark - public method

- (void)configureWithView:(UIView *)view previewRect:(CGRect)preivewRect
{
    self.previewLayer.frame = preivewRect;
    [view.layer addSublayer:self.previewLayer];
}

- (void)startRunning
{
    dispatch_async(self.sessionQueue, ^{
        [self.captureSession startRunning];
    });
}

- (void)stopRunning
{
    [self.captureSession stopRunning];
}

- (void)takePhoto:(void (^)(UIImage *))block
{
    UIImage *image = [UIImage imageWithCGImage:self.currentImage];
    block(image);
}

- (void)switchCamera
{
    NSUInteger cameraCount = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
    if (cameraCount > 1) {
        AVCaptureDeviceInput *newInput;
        AVCaptureDevicePosition position = self.inputDevice.device.position;
        
        if (position == AVCaptureDevicePositionBack) {
            newInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.frontCamera error:nil];
        } else if (position == AVCaptureDevicePositionFront) {
            newInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.backCamera error:nil];
        }
        
        if (newInput) {
            [self.captureSession beginConfiguration];
            [self.captureSession removeInput:self.inputDevice];
            
            if ([self.captureSession canAddInput:newInput]) {
                [self.captureSession addInput:newInput];
            }
            [self.captureSession commitConfiguration];
            self.inputDevice = newInput;
        }
    }
}

- (void)focusInPoint:(CGPoint)point
{
    dispatch_async(self.sessionQueue, ^{
        
        CGPoint devicePoint = [self convertToPointOfInterestFromViewCoordinates:point];
        AVCaptureDevice *device = self.inputDevice.device;
        
        if ([device lockForConfiguration:nil]) {
            AVCaptureFocusMode focusMode = AVCaptureFocusModeAutoFocus;
            AVCaptureExposureMode exposureMode = AVCaptureExposureModeAutoExpose;
            
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode]) {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:devicePoint];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode]) {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:devicePoint];
            }
            [device setSubjectAreaChangeMonitoringEnabled:YES];
            [device unlockForConfiguration];
        }
    });
}

- (NSString *)currentFlashMode
{
    NSString *result = nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasFlash]) {
        if (device.flashMode == AVCaptureFlashModeOff) {
            result = @"Off";
        } else if (device.flashMode == AVCaptureFlashModeOn) {
            result = @"On";
        } else if (device.flashMode == AVCaptureFlashModeAuto) {
            result = @"Auto";
        }
    }
    
    return result;
}

- (void)switchFlashMode
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    if ([device hasFlash]) {
        if (device.flashMode == AVCaptureFlashModeOff) {
            device.flashMode = AVCaptureFlashModeOn;
        } else if (device.flashMode == AVCaptureFlashModeOn) {
            device.flashMode = AVCaptureFlashModeAuto;
        } else if (device.flashMode == AVCaptureFlashModeAuto) {
            device.flashMode = AVCaptureFlashModeOff;
        }
    }
    
    [device unlockForConfiguration];
}

#pragma mark - private method

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    
    CGRect cleanAperture;
    for(AVCaptureInputPort *port in [[self.captureSession.inputs lastObject]ports]) {
        if([port mediaType] == AVMediaTypeVideo) {
            cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
            
            CGFloat xc = .5f;
            CGFloat yc = .5f;
            
            pointOfInterest = CGPointMake(xc, yc);
            break;
        }
    }
    
    return pointOfInterest;
}

- (CIContext *)imageContext
{
    if (!_imageContext) {
        
        EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        NSDictionary *options = @{kCIContextWorkingColorSpace: [NSNull null]};
        
        _imageContext = [CIContext contextWithEAGLContext:context options:options];
    }
    
    return _imageContext;
}

@end
