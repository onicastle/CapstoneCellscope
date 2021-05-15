//
//  OpenCVWrapper.h
//  Cellscope
//
//  Created by marcos joel gonzález on 5/9/21.
//  Adapted from https://medium.com/salt-pepper/opencv-swift-wrapper-6947ba236809

#import <Foundation/Foundation.h>

#import "OpenCVWrapper.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+ (UIImage *)toGray:(UIImage *)source;
+ (UIImage *)thresholding:(UIImage *)source;
+ (UIImage *)brightfield:(UIImage *)source1 andImage2:(UIImage *)source2;
+ (UIImage *)dpc:(UIImage *)source1 andImage2:(UIImage *)source2;
+ (UIImage *)convolve:(UIImage *)source;
+ (UIImage *)fourier:(UIImage *)source;

@end

NS_ASSUME_NONNULL_END
