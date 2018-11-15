//
//  UIBezierPath+Shapes.m
//  CBZSplashView
//
//  Created by Mazyad Alabduljaleel on 8/8/14.
//  Copyright (c) 2014 Callum Boddy. All rights reserved.
//

#import "UIBezierPath+Shapes.h"

@implementation UIBezierPath (Shapes)

+ (instancetype)ebolaShape
{
    UIBezierPath* path = UIBezierPath.bezierPath;
    [path moveToPoint: CGPointMake(73.4, 71.21)];
    [path addCurveToPoint: CGPointMake(48.17, 45.49) controlPoint1: CGPointMake(73.4, 57.01) controlPoint2: CGPointMake(62.1, 45.49)];
    [path addCurveToPoint: CGPointMake(22.94, 71.21) controlPoint1: CGPointMake(34.24, 45.49) controlPoint2: CGPointMake(22.94, 57.01)];
    [path addCurveToPoint: CGPointMake(48.17, 96.92) controlPoint1: CGPointMake(22.94, 85.41) controlPoint2: CGPointMake(34.24, 96.92)];
    [path addCurveToPoint: CGPointMake(73.4, 71.21) controlPoint1: CGPointMake(62.1, 96.92) controlPoint2: CGPointMake(73.4, 85.41)];
    [path closePath];
    [path moveToPoint: CGPointMake(48.17, 90.49)];
    [path addCurveToPoint: CGPointMake(29.25, 71.21) controlPoint1: CGPointMake(37.72, 90.49) controlPoint2: CGPointMake(29.25, 81.86)];
    [path addCurveToPoint: CGPointMake(48.17, 51.92) controlPoint1: CGPointMake(29.25, 60.56) controlPoint2: CGPointMake(37.72, 51.92)];
    [path addCurveToPoint: CGPointMake(67.09, 71.21) controlPoint1: CGPointMake(58.62, 51.92) controlPoint2: CGPointMake(67.09, 60.56)];
    [path addCurveToPoint: CGPointMake(48.17, 90.49) controlPoint1: CGPointMake(67.09, 81.86) controlPoint2: CGPointMake(58.62, 90.49)];
    [path closePath];
    [path moveToPoint: CGPointMake(92.32, 109.78)];
    [path addLineToPoint: CGPointMake(92.32, 106.56)];
    [path addCurveToPoint: CGPointMake(82.86, 96.92) controlPoint1: CGPointMake(92.32, 101.24) controlPoint2: CGPointMake(88.09, 96.92)];
    [path addCurveToPoint: CGPointMake(73.4, 106.56) controlPoint1: CGPointMake(77.64, 96.92) controlPoint2: CGPointMake(73.4, 101.24)];
    [path addLineToPoint: CGPointMake(73.4, 109.78)];
    [path addCurveToPoint: CGPointMake(63.94, 119.42) controlPoint1: CGPointMake(68.17, 109.78) controlPoint2: CGPointMake(63.94, 114.1)];
    [path addCurveToPoint: CGPointMake(73.4, 129.06) controlPoint1: CGPointMake(63.94, 124.75) controlPoint2: CGPointMake(68.17, 129.06)];
    [path addLineToPoint: CGPointMake(92.32, 129.06)];
    [path addCurveToPoint: CGPointMake(101.78, 119.42) controlPoint1: CGPointMake(97.55, 129.06) controlPoint2: CGPointMake(101.78, 124.75)];
    [path addCurveToPoint: CGPointMake(92.32, 109.78) controlPoint1: CGPointMake(101.78, 114.1) controlPoint2: CGPointMake(97.55, 109.78)];
    [path closePath];
    [path moveToPoint: CGPointMake(92.32, 122.64)];
    [path addLineToPoint: CGPointMake(73.4, 122.64)];
    [path addCurveToPoint: CGPointMake(70.25, 119.42) controlPoint1: CGPointMake(71.66, 122.64) controlPoint2: CGPointMake(70.25, 121.2)];
    [path addCurveToPoint: CGPointMake(73.4, 116.21) controlPoint1: CGPointMake(70.25, 117.65) controlPoint2: CGPointMake(71.66, 116.21)];
    [path addCurveToPoint: CGPointMake(79.71, 109.78) controlPoint1: CGPointMake(79.71, 116.21) controlPoint2: CGPointMake(79.71, 109.78)];
    [path addLineToPoint: CGPointMake(79.71, 106.56)];
    [path addCurveToPoint: CGPointMake(82.86, 103.35) controlPoint1: CGPointMake(79.71, 104.79) controlPoint2: CGPointMake(81.12, 103.35)];
    [path addCurveToPoint: CGPointMake(86.02, 106.56) controlPoint1: CGPointMake(84.61, 103.35) controlPoint2: CGPointMake(86.02, 104.79)];
    [path addLineToPoint: CGPointMake(86.02, 109.78)];
    [path addCurveToPoint: CGPointMake(92.32, 116.21) controlPoint1: CGPointMake(86.02, 116.21) controlPoint2: CGPointMake(92.32, 116.21)];
    [path addCurveToPoint: CGPointMake(95.48, 119.42) controlPoint1: CGPointMake(94.07, 116.21) controlPoint2: CGPointMake(95.48, 117.65)];
    [path addCurveToPoint: CGPointMake(92.32, 122.64) controlPoint1: CGPointMake(95.48, 121.2) controlPoint2: CGPointMake(94.07, 122.64)];
    [path closePath];
    [path moveToPoint: CGPointMake(82.86, 0.49)];
    [path addCurveToPoint: CGPointMake(0.86, 74.42) controlPoint1: CGPointMake(37.58, 0.49) controlPoint2: CGPointMake(0.86, 33.59)];
    [path addCurveToPoint: CGPointMake(19.78, 121.52) controlPoint1: CGPointMake(0.86, 92.35) controlPoint2: CGPointMake(8, 108.74)];
    [path addLineToPoint: CGPointMake(19.78, 148.35)];
    [path addCurveToPoint: CGPointMake(45.02, 174.06) controlPoint1: CGPointMake(19.78, 162.55) controlPoint2: CGPointMake(31.08, 174.06)];
    [path addCurveToPoint: CGPointMake(62.55, 166.81) controlPoint1: CGPointMake(51.83, 174.06) controlPoint2: CGPointMake(58.01, 171.3)];
    [path addCurveToPoint: CGPointMake(82.86, 180.49) controlPoint1: CGPointMake(65.92, 174.86) controlPoint2: CGPointMake(73.74, 180.49)];
    [path addCurveToPoint: CGPointMake(103.17, 166.81) controlPoint1: CGPointMake(91.98, 180.49) controlPoint2: CGPointMake(99.8, 174.86)];
    [path addCurveToPoint: CGPointMake(120.71, 174.06) controlPoint1: CGPointMake(107.71, 171.3) controlPoint2: CGPointMake(113.89, 174.06)];
    [path addCurveToPoint: CGPointMake(145.94, 148.35) controlPoint1: CGPointMake(134.64, 174.06) controlPoint2: CGPointMake(145.94, 162.55)];
    [path addLineToPoint: CGPointMake(145.94, 121.52)];
    [path addCurveToPoint: CGPointMake(164.86, 74.42) controlPoint1: CGPointMake(157.73, 108.74) controlPoint2: CGPointMake(164.86, 92.35)];
    [path addCurveToPoint: CGPointMake(82.86, 0.49) controlPoint1: CGPointMake(164.86, 33.59) controlPoint2: CGPointMake(128.15, 0.49)];
    [path closePath];
    [path moveToPoint: CGPointMake(139.63, 119.01)];
    [path addLineToPoint: CGPointMake(139.63, 148.35)];
    [path addCurveToPoint: CGPointMake(120.71, 167.64) controlPoint1: CGPointMake(139.63, 159) controlPoint2: CGPointMake(131.16, 167.64)];
    [path addCurveToPoint: CGPointMake(104.18, 157.55) controlPoint1: CGPointMake(113.55, 167.64) controlPoint2: CGPointMake(107.39, 163.53)];
    [path addLineToPoint: CGPointMake(104.05, 157.63)];
    [path addCurveToPoint: CGPointMake(101.59, 156.18) controlPoint1: CGPointMake(103.53, 156.78) controlPoint2: CGPointMake(102.65, 156.18)];
    [path addCurveToPoint: CGPointMake(98.67, 159) controlPoint1: CGPointMake(100.03, 156.18) controlPoint2: CGPointMake(98.78, 157.43)];
    [path addLineToPoint: CGPointMake(98.53, 159)];
    [path addCurveToPoint: CGPointMake(82.86, 174.06) controlPoint1: CGPointMake(98.01, 167.4) controlPoint2: CGPointMake(91.23, 174.06)];
    [path addCurveToPoint: CGPointMake(67.19, 159) controlPoint1: CGPointMake(74.49, 174.06) controlPoint2: CGPointMake(67.71, 167.4)];
    [path addLineToPoint: CGPointMake(67.05, 159)];
    [path addCurveToPoint: CGPointMake(64.13, 156.18) controlPoint1: CGPointMake(66.94, 157.43) controlPoint2: CGPointMake(65.7, 156.18)];
    [path addCurveToPoint: CGPointMake(61.65, 157.65) controlPoint1: CGPointMake(63.07, 156.18) controlPoint2: CGPointMake(62.18, 156.79)];
    [path addLineToPoint: CGPointMake(61.53, 157.58)];
    [path addCurveToPoint: CGPointMake(45.02, 167.64) controlPoint1: CGPointMake(58.32, 163.55) controlPoint2: CGPointMake(52.17, 167.64)];
    [path addCurveToPoint: CGPointMake(26.09, 148.35) controlPoint1: CGPointMake(34.57, 167.64) controlPoint2: CGPointMake(26.09, 159)];
    [path addLineToPoint: CGPointMake(26.09, 119.01)];
    [path addCurveToPoint: CGPointMake(7.17, 74.42) controlPoint1: CGPointMake(14.33, 107.12) controlPoint2: CGPointMake(7.17, 91.52)];
    [path addCurveToPoint: CGPointMake(82.86, 6.92) controlPoint1: CGPointMake(7.17, 37.14) controlPoint2: CGPointMake(41.06, 6.92)];
    [path addCurveToPoint: CGPointMake(158.55, 74.42) controlPoint1: CGPointMake(124.67, 6.92) controlPoint2: CGPointMake(158.55, 37.14)];
    [path addCurveToPoint: CGPointMake(139.63, 119.01) controlPoint1: CGPointMake(158.55, 91.52) controlPoint2: CGPointMake(151.39, 107.12)];
    [path closePath];
    [path moveToPoint: CGPointMake(117.55, 45.49)];
    [path addCurveToPoint: CGPointMake(92.32, 71.21) controlPoint1: CGPointMake(103.62, 45.49) controlPoint2: CGPointMake(92.32, 57.01)];
    [path addCurveToPoint: CGPointMake(117.55, 96.92) controlPoint1: CGPointMake(92.32, 85.41) controlPoint2: CGPointMake(103.62, 96.92)];
    [path addCurveToPoint: CGPointMake(142.78, 71.21) controlPoint1: CGPointMake(131.49, 96.92) controlPoint2: CGPointMake(142.78, 85.41)];
    [path addCurveToPoint: CGPointMake(117.55, 45.49) controlPoint1: CGPointMake(142.78, 57.01) controlPoint2: CGPointMake(131.49, 45.49)];
    [path closePath];
    [path moveToPoint: CGPointMake(117.55, 90.49)];
    [path addCurveToPoint: CGPointMake(98.63, 71.21) controlPoint1: CGPointMake(107.1, 90.49) controlPoint2: CGPointMake(98.63, 81.86)];
    [path addCurveToPoint: CGPointMake(117.55, 51.92) controlPoint1: CGPointMake(98.63, 60.56) controlPoint2: CGPointMake(107.1, 51.92)];
    [path addCurveToPoint: CGPointMake(136.48, 71.21) controlPoint1: CGPointMake(128, 51.92) controlPoint2: CGPointMake(136.48, 60.56)];
    [path addCurveToPoint: CGPointMake(117.55, 90.49) controlPoint1: CGPointMake(136.48, 81.86) controlPoint2: CGPointMake(128, 90.49)];
    [path closePath];
    path.miterLimit = 4;
    
    return path;
}

@end
