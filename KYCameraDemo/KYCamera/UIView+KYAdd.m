//
//  UIView+KYAdd.m
//  KYTagViewDemo
//
//  Created by KangYang on 16/1/16.
//  Copyright © 2016年 KangYang. All rights reserved.
//

#import "UIView+KYAdd.h"

@implementation UIView (KYAdd)

- (CGFloat)minX
{
    return CGRectGetMinX(self.frame);
}

- (void)setMinX:(CGFloat)minX
{
    CGRect frame = self.frame;
    frame.origin.x = minX;
    self.frame = frame;
}

- (CGFloat)maxX
{
    return CGRectGetMaxX(self.frame);
}

- (void)setMaxX:(CGFloat)maxX
{
    CGRect frame = self.frame;
    frame.origin.x = maxX - frame.size.width;
    self.frame = frame;
}

- (CGFloat)minY
{
    return CGRectGetMinY(self.frame);
}

- (void)setMinY:(CGFloat)minY
{
    CGRect frame = self.frame;
    frame.origin.y = minY;
    self.frame = frame;
}

- (CGFloat)maxY
{
    return CGRectGetMaxY(self.frame);
}

- (void)setMaxY:(CGFloat)maxY
{
    CGRect frame = self.frame;
    frame.origin.y = maxY - frame.size.height;
    self.frame = frame;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)width
{
    return CGRectGetWidth(self.frame);
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height
{
    return CGRectGetHeight(self.frame);
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

@end
