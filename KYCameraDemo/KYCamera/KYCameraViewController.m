//
//  KYCameraViewController.m
//  KYCameraDemo
//
//  Created by KangYang on 16/1/30.
//  Copyright © 2016年 KangYang. All rights reserved.
//

#import "KYCameraViewController.h"
#import "UIView+KYAdd.h"

#define kHeaderHeight   55

NSString * const kCollectionViewCellReuseIdentifierKey = @"reuseIdentifier";

@interface KYCameraViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong, nonatomic) KYCaptureSessionManager *captureManager;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UICollectionView *collectionView;

@property (copy, nonatomic) NSArray *filters;

@end

@implementation KYCameraViewController

#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self _configureCaptureManager];
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.bottomView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.captureManager startRunning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.captureManager stopRunning];
}

- (void)dealloc
{
    self.captureManager = nil;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - event response

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(self.captureManager.previewLayer.frame, location)) {
        location.y -= kHeaderHeight;
        [self.captureManager focusInPoint:location];
    }
}

- (void)closeButtonAction:(UIButton *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)flashButtonAction:(UIButton *)sender
{
    [self.captureManager switchFlashMode];
    [sender setTitle:[self.captureManager currentFlashMode] forState:UIControlStateNormal];
}

- (void)switchButtonAction:(UIButton *)sender
{
    [self.captureManager switchCamera];
}

- (void)shutterButtonAction:(UIButton *)sender
{
    [self.captureManager takePhoto:^(UIImage *image) {
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.filters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellReuseIdentifierKey
                                                                           forIndexPath:indexPath];
    
    UIImageView *imageView = [cell.contentView viewWithTag:99];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        imageView.backgroundColor = [UIColor grayColor];
        imageView.tag = 99;
        [cell.contentView addSubview:imageView];
    }
    
    UILabel *label = [cell.contentView viewWithTag:98];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 60, 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor whiteColor];
        label.tag = 98;
        [cell.contentView addSubview:label];
    }
    label.text = self.filters[indexPath.item][@"displayName"];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CIFilter *filter = [CIFilter filterWithName:self.filters[indexPath.item][@"className"]];
    self.captureManager.userFilter = filter;
}

#pragma mark - private method

- (void)_configureCaptureManager
{
    _captureManager = [[KYCaptureSessionManager alloc] init];
    [_captureManager configureWithView:self.view previewRect:CGRectMake(0, kHeaderHeight, self.view.width, self.view.width)];
}

#pragma mark - getters and setters

- (UIView *)headerView
{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kHeaderHeight)];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake(0, 0, kHeaderHeight, kHeaderHeight)];
        [closeButton setImage:[UIImage imageNamed:@"camera_close"] forState:UIControlStateNormal];
        [closeButton setImage:[UIImage imageNamed:@"camera_close_press"] forState:UIControlStateHighlighted];
        [closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:closeButton];
        
        UIButton *switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [switchCameraButton setFrame:CGRectMake((self.view.width - kHeaderHeight) / 2, 0, kHeaderHeight, kHeaderHeight)];
        [switchCameraButton setImage:[UIImage imageNamed:@"switch_camera"] forState:UIControlStateNormal];
        [switchCameraButton setImage:[UIImage imageNamed:@"switch_camera_press"] forState:UIControlStateHighlighted];
        [switchCameraButton addTarget:self action:@selector(switchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:switchCameraButton];
        
        UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [flashButton setFrame:CGRectMake(self.view.width - 80, 0, 80, kHeaderHeight)];
        [flashButton setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
        [flashButton setTitle:[self.captureManager currentFlashMode] forState:UIControlStateNormal];
        [flashButton addTarget:self action:@selector(flashButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:flashButton];
    }
    
    return _headerView;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        CGFloat contentY  = kHeaderHeight + self.captureManager.previewLayer.frame.size.height;
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, contentY, self.view.width, self.view.height - contentY)];
        
        [_bottomView addSubview:self.collectionView];
        
        UIButton *shutterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shutterButton setFrame:CGRectMake((self.view.width - 75) / 2, _bottomView.height - 85, 75, 75)];
        [shutterButton setImage:[UIImage imageNamed:@"shutter"] forState:UIControlStateNormal];
        [shutterButton addTarget:self action:@selector(shutterButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:shutterButton];
    }
    
    return _bottomView;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 5;
        layout.minimumLineSpacing = 5;
        layout.itemSize = CGSizeMake(60, 80);
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 10, self.view.width, 80) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCollectionViewCellReuseIdentifierKey];
    }
    return _collectionView;
}

- (NSArray *)filters
{
    if (!_filters) {
        _filters = @[@{@"className": @"CIColorControls", @"displayName": @"None"},
                     @{@"className": @"CIPhotoEffectMono", @"displayName": @"Mono"},
                     @{@"className": @"CIPhotoEffectTonal", @"displayName": @"Tonal"},
                     @{@"className": @"CIPhotoEffectNoir", @"displayName": @"Noir"},
                     @{@"className": @"CIPhotoEffectFade", @"displayName": @"Fade"},
                     @{@"className": @"CIPhotoEffectChrome", @"displayName": @"Chrome"},
                     @{@"className": @"CIPhotoEffectProcess", @"displayName": @"Process"},
                     @{@"className": @"CIPhotoEffectTransfer", @"displayName": @"Transfer"},
                     @{@"className": @"CIPhotoEffectInstant", @"displayName": @"Instant"}];
    }
    return _filters;
}

@end
