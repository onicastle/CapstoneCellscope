//
//  OpenCVWrapper.mm
//  Cellscope
//
//  Created by marcos joel gonzález on 5/9/21.
//  Adapted from https://medium.com/salt-pepper/opencv-swift-wrapper-6947ba236809
//

#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

int threshold_value = 0;
int threshold_type = 0;
int const max_value = 255;
int const max_type = 4;
int const max_binary_value = 255;

/* Threshold types
     0: Binary
     1: Binary Inverted
     2: Threshold Truncated
     3: Threshold to Zero
     4: Threshold to Zero Inverted
    */

@implementation OpenCVWrapper

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

#pragma mark Public
+ (UIImage *)toGray:(UIImage *)source {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _grayFrom:[OpenCVWrapper _matFrom:source]]];
}

#pragma mark Public
+ (UIImage *)thresholding:(UIImage *)source {
    cout << "OpenCV: ";
    Mat dst;
    threshold([OpenCVWrapper _grayFrom:[OpenCVWrapper _matFrom:source]], dst, threshold_value, max_binary_value, threshold_type);
    return [OpenCVWrapper _imageFrom:dst];
}

#pragma mark Public
+ (UIImage *)brightfield:(UIImage *)source1 andImage2:(UIImage *)source2 {
    cout << "OpenCV: ";
    Mat dst;
    Mat source1Mat = [OpenCVWrapper _grayFrom:[OpenCVWrapper _matFrom:source1]];
    Mat source2Mat = [OpenCVWrapper _grayFrom:[OpenCVWrapper _matFrom:source2]];
    
    // to crop to the biggest possible area
    int dimensions[4] = {source1Mat.cols, source1Mat.rows, source2Mat.cols, source2Mat.rows};
    int minDimension = dimensions[0];
    for (int i=1; i<(int)(sizeof(dimensions)/sizeof(*dimensions)); i++) {
        if (dimensions[i] < minDimension) minDimension = dimensions[i];
    }
    
    Mat source1Cropped = source1Mat(cv::Rect(source1Mat.cols/2-minDimension/2, source1Mat.rows/2-minDimension/2, minDimension, minDimension));
    Mat source2Cropped = source2Mat(cv::Rect(source2Mat.cols/2-minDimension/2, source2Mat.rows/2-minDimension/2, minDimension, minDimension));
    
    // I_bf = I_left + I_right
    cv::add(source1Cropped, source2Cropped, dst);
    return [OpenCVWrapper _imageFrom:dst];
}

#pragma mark Public
+ (UIImage *)dpc:(UIImage *)source1 andImage2:(UIImage *)source2 {
    cout << "OpenCV: ";
    Mat numerator, denominator, dst;
    Mat source1Mat = [OpenCVWrapper _grayFrom:[OpenCVWrapper _matFrom:source1]];
    Mat source2Mat = [OpenCVWrapper _grayFrom:[OpenCVWrapper _matFrom:source2]];
    
    // to crop to the biggest possible area
    int dimensions[4] = {source1Mat.cols, source1Mat.rows, source2Mat.cols, source2Mat.rows};
    int minDimension = dimensions[0];
    for (int i=1; i<(int)(sizeof(dimensions)/sizeof(*dimensions)); i++) {
        if (dimensions[i] < minDimension) minDimension = dimensions[i];
    }
    
    Mat source1Cropped = source1Mat(cv::Rect(source1Mat.cols/2-minDimension/2, source1Mat.rows/2-minDimension/2, minDimension, minDimension));
    Mat source2Cropped = source2Mat(cv::Rect(source2Mat.cols/2-minDimension/2, source2Mat.rows/2-minDimension/2, minDimension, minDimension));
    
    // I_bf = I_left - I_right / I_left + I_right
    cv::subtract(source1Cropped, source2Cropped, numerator);
    cv::add(source1Cropped, source2Cropped, denominator);
    cv::divide(numerator, denominator, dst);
    return [OpenCVWrapper _imageFrom:dst];
}

// adapted from https://docs.opencv.org/3.4/d4/dbd/tutorial_filter_2d.html
#pragma mark Public
+ (UIImage *)convolve:(UIImage *)source {
    cout << "OpenCV: ";
    Mat dst;
    int arr[3][3] = {{0, -1, 0}, {-1, 5, -1}, {0, -1, 0}};
    Mat kernel = Mat(3, 3, CV_16U, arr);
    Mat src = [OpenCVWrapper _matFrom:source];
    cv::Point anchor;
    double delta;
    int ddepth;

    // Initialize arguments for the filter
    anchor = cv::Point( -1, -1 );
    delta = 0;
    ddepth = -1;

    filter2D(src, dst, ddepth , kernel, anchor, delta, BORDER_DEFAULT );

    return [OpenCVWrapper _imageFrom:dst];
}

// adapted from https://docs.opencv.org/3.4/d8/d01/tutorial_discrete_fourier_transform.html
#pragma mark Public
+ (UIImage *)fourier:(UIImage *)source {
    cout << "OpenCV: ";
    Mat sourceMat = [OpenCVWrapper _grayFrom:[OpenCVWrapper _matFrom:source]];
    
    Mat padded;                            //expand input image to optimal size
    int m = getOptimalDFTSize( sourceMat.rows );
    int n = getOptimalDFTSize( sourceMat.cols ); // on the border add zero values
    copyMakeBorder(sourceMat, padded, 0, m - sourceMat.rows, 0, n - sourceMat.cols, BORDER_CONSTANT, Scalar::all(0));
    Mat planes[] = {Mat_<float>(padded), Mat::zeros(padded.size(), CV_32F)};
    Mat complexI;
    merge(planes, 2, complexI);         // Add to the expanded another plane with zeros
    dft(complexI, complexI);            // this way the result may fit in the source matrix
    // compute the magnitude and switch to logarithmic scale
    // => log(1 + sqrt(Re(DFT(I))^2 + Im(DFT(I))^2))
    split(complexI, planes);                   // planes[0] = Re(DFT(I), planes[1] = Im(DFT(I))
    magnitude(planes[0], planes[1], planes[0]);// planes[0] = magnitude
    Mat magSourceMat = planes[0];
    magSourceMat += Scalar::all(1);                    // switch to logarithmic scale
    log(magSourceMat, magSourceMat);
    // crop the spectrum, if it has an odd number of rows or columns
    magSourceMat = magSourceMat(cv::Rect(0, 0, magSourceMat.cols & -2, magSourceMat.rows & -2));
    // rearrange the quadrants of Fourier image  so that the origin is at the image center
    int cx = magSourceMat.cols/2;
    int cy = magSourceMat.rows/2;
    Mat q0(magSourceMat, cv::Rect(0, 0, cx, cy));   // Top-Left - Create a ROI per quadrant
    Mat q1(magSourceMat, cv::Rect(cx, 0, cx, cy));  // Top-Right
    Mat q2(magSourceMat, cv::Rect(0, cy, cx, cy));  // Bottom-Left
    Mat q3(magSourceMat, cv::Rect(cx, cy, cx, cy)); // Bottom-Right
    Mat tmp;                           // swap quadrants (Top-Left with Bottom-Right)
    q0.copyTo(tmp);
    q3.copyTo(q0);
    tmp.copyTo(q3);
    q1.copyTo(tmp);                    // swap quadrant (Top-Right with Bottom-Left)
    q2.copyTo(q1);
    tmp.copyTo(q2);
    normalize(magSourceMat, magSourceMat, 0, 1, NORM_MINMAX); // Transform the matrix with float values into a
                                                // viewable image form (float between values 0 and 1).
    return [OpenCVWrapper _imageFrom:magSourceMat];
}


#pragma mark Private
+ (Mat)_grayFrom:(Mat)source {
    cout << "-> grayFrom ->";
    Mat result;
    cvtColor(source, result, COLOR_BGR2GRAY);
    return result;
}

+ (Mat)_matFrom:(UIImage *)source {
    cout << "matFrom ->";
    CGImageRef image = CGImageCreateCopy(source.CGImage);
    CGFloat cols = CGImageGetWidth(image);
    CGFloat rows = CGImageGetHeight(image);
    Mat result(rows, cols, CV_8UC4);
    CGBitmapInfo bitmapFlags = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = result.step[0];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    CGContextRef context = CGBitmapContextCreate(result.data, cols, rows, bitsPerComponent, bytesPerRow, colorSpace, bitmapFlags);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, cols, rows), image);
    CGContextRelease(context);
    return result;
}

+ (UIImage *)_imageFrom:(Mat)source {
    cout << "-> imageFrom\n";
    NSData *data = [NSData dataWithBytes:source.data length:source.elemSize() * source.total()];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGBitmapInfo bitmapFlags = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = source.step[0];
    CGColorSpaceRef colorSpace = (source.elemSize() == 1 ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB());
    CGImageRef image = CGImageCreate(source.cols, source.rows, bitsPerComponent, bitsPerComponent * source.elemSize(), bytesPerRow, colorSpace, bitmapFlags, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *result = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return result;
}

@end

