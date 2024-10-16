//
//  TTSDKCrashError.h
//
//  Created by Gleb Linnik on 12.07.2024.
//
//  Copyright (c) 2012 Karl Stenerud. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#ifndef TTSDKCrashError_h
#define TTSDKCrashError_h

#ifdef __OBJC__
#include <Foundation/Foundation.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __OBJC__
static NSErrorDomain const TTSDKCrashErrorDomain = @"TTSDKCrashErrorDomain";
#endif

typedef
#ifdef __OBJC__
    NS_ERROR_ENUM(TTSDKCrashErrorDomain, TTSDKCrashInstallErrorCode)
#else  /* __OBJC__ */
    enum
#endif /* __OBJC__ */
{ TTSDKCrashInstallErrorNone = 0,
  TTSDKCrashInstallErrorAlreadyInstalled,
  TTSDKCrashInstallErrorInvalidParameter,
  TTSDKCrashInstallErrorPathTooLong,
  TTSDKCrashInstallErrorCouldNotCreatePath,
  TTSDKCrashInstallErrorCouldNotInitializeStore,
  TTSDKCrashInstallErrorCouldNotInitializeMemory,
  TTSDKCrashInstallErrorCouldNotInitializeCrashState,
  TTSDKCrashInstallErrorCouldNotSetLogFilename,
  TTSDKCrashInstallErrorNoActiveMonitors }
#ifndef __OBJC__
TTSDKCrashInstallErrorCode
#endif
    ;

#ifdef __cplusplus
}
#endif

#endif /* TTSDKCrashError_h */
