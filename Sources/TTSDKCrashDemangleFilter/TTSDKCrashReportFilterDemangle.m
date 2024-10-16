//
//  TTSDKCrashReportFilterDemangle.m
//
//  Created by Nikolay Volosatov on 2024-08-16.
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

#import "TTSDKCrashReportFilterDemangle.h"

#import "TTSDKCrashReport.h"
#import "TTSDKCrashReportFields.h"
#import "TTSDKDemangle_CPP.h"
#import "TTSDKSystemCapabilities.h"
#if TTSDKCRASH_HAS_SWIFT
#import "TTSDKDemangle_Swift.h"
#endif

// #define TTSDKLogger_LocalLevel TRACE
#import "TTSDKLogger.h"

@interface TTSDKCrashReportFilterDemangle ()

@end

@implementation TTSDKCrashReportFilterDemangle

+ (NSString *)demangledCppSymbol:(NSString *)symbol
{
    char *demangled = ttsdkdm_demangleCPP(symbol.UTF8String);
    if (demangled != NULL) {
        NSString *result = [[NSString alloc] initWithBytesNoCopy:demangled
                                                          length:strlen(demangled)
                                                        encoding:NSUTF8StringEncoding
                                                    freeWhenDone:YES];
        TTSDKLOG_DEBUG(@"Demangled a C++ symbol '%@' -> '%@'", symbol, result);
        return result;
    }
    return nil;
}

+ (NSString *)demangledSwiftSymbol:(NSString *)symbol
{
#if TTSDKCRASH_HAS_SWIFT
    char *demangled = ttsdkdm_demangleSwift(symbol.UTF8String);
    if (demangled != NULL) {
        NSString *result = [[NSString alloc] initWithBytesNoCopy:demangled
                                                          length:strlen(demangled)
                                                        encoding:NSUTF8StringEncoding
                                                    freeWhenDone:YES];
        TTSDKLOG_DEBUG(@"Demangled a Swift symbol '%@' -> '%@'", symbol, result);
        return result;
    }
#endif
    return nil;
}

+ (NSString *)demangledSymbol:(NSString *)symbol
{
    return [self demangledCppSymbol:symbol] ?: [self demangledSwiftSymbol:symbol];
}

/** Recurcively demangles strings within the report.
 * @param reportObj An object within the report (dictionary, array, string etc)
 * @param path An array of strings representing keys in dictionaries. An empty key means an itteration within the array.
 * @param depth Current depth of the path
 * @return An updated object or `nil` if no changes were applied.
 */
+ (id)demangleReportObj:(id)reportObj path:(NSArray<NSString *> *)path depth:(NSUInteger)depth
{
    // Check for NSString and try demangle
    if (depth == path.count) {
        if ([reportObj isKindOfClass:[NSString class]] == NO) {
            return nil;
        }
        NSString *demangled = [self demangledSymbol:reportObj];
        return demangled;
    }

    NSString *pathComponent = path[depth];

    // NSArray:
    if (pathComponent.length == 0) {
        if ([reportObj isKindOfClass:[NSArray class]] == NO) {
            return nil;
        }
        NSArray *reportArray = reportObj;
        NSMutableArray *__block result = nil;
        [reportArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *_Nonnull stop) {
            id demangled = [self demangleReportObj:obj path:path depth:depth + 1];
            if (demangled != nil && result == nil) {
                // Initializing the updated array only on first demangled result
                result = [NSMutableArray arrayWithCapacity:reportArray.count];
                for (NSUInteger subIdx = 0; subIdx < idx; ++subIdx) {
                    [result addObject:reportArray[subIdx]];
                }
            }
            result[idx] = demangled ?: obj;
        }];
        return [result copy];
    }

    // NSDictionary:
    if ([reportObj isKindOfClass:[NSDictionary class]] == NO) {
        return nil;
    }
    NSDictionary *reportDict = reportObj;
    id demangledElement = [self demangleReportObj:reportDict[pathComponent] path:path depth:depth + 1];
    if (demangledElement == nil) {
        return nil;
    }
    NSMutableDictionary *result = [reportDict mutableCopy];
    result[pathComponent] = demangledElement;
    return [result copy];
}

#pragma mark - TTSDKCrashReportFilter

- (void)filterReports:(NSArray<id<TTSDKCrashReport>> *)reports onCompletion:(TTSDKCrashReportFilterCompletion)onCompletion
{
    NSArray *demanglePaths = @[
        @[
            TTSDKCrashField_Crash, TTSDKCrashField_Threads, @"", TTSDKCrashField_Backtrace, TTSDKCrashField_Contents, @"",
            TTSDKCrashField_SymbolName
        ],
        @[
            TTSDKCrashField_RecrashReport, TTSDKCrashField_Crash, TTSDKCrashField_Threads, @"", TTSDKCrashField_Backtrace,
            TTSDKCrashField_Contents, @"", TTSDKCrashField_SymbolName
        ],
        @[ TTSDKCrashField_Crash, TTSDKCrashField_Error, TTSDKCrashField_CPPException, TTSDKCrashField_Name ],
        @[
            TTSDKCrashField_RecrashReport, TTSDKCrashField_Crash, TTSDKCrashField_Error, TTSDKCrashField_CPPException,
            TTSDKCrashField_Name
        ],
    ];

    NSMutableArray<id<TTSDKCrashReport>> *filteredReports = [NSMutableArray arrayWithCapacity:[reports count]];
    for (TTSDKCrashReportDictionary *report in reports) {
        if ([report isKindOfClass:[TTSDKCrashReportDictionary class]] == NO) {
            TTSDKLOG_ERROR(@"Unexpected non-dictionary report: %@", report);
            continue;
        }
        NSDictionary *reportDict = report.value;
        for (NSArray *path in demanglePaths) {
            reportDict = [[self class] demangleReportObj:reportDict path:path depth:0] ?: reportDict;
        }
        [filteredReports addObject:[TTSDKCrashReportDictionary reportWithValue:reportDict]];
    }

    ttsdkcrash_callCompletion(onCompletion, filteredReports, nil);
}

@end
