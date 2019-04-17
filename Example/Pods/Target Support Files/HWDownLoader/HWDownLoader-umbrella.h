#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HWDownLoader.h"
#import "HWDownLoaderManager.h"
#import "NSString+Hash.h"

FOUNDATION_EXPORT double HWDownLoaderVersionNumber;
FOUNDATION_EXPORT const unsigned char HWDownLoaderVersionString[];

