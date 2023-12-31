//
//  REFGlyphNameResolver.m
//  ReferenceGlyph
//
//  Created by tfuji on 17/12/2017.
//  Copyright © 2017 Morisawa Inc. All rights reserved.
//

#import "REFGlyphNameResolver.h"
#import <GlyphsCore/GSFont.h>
#import <GlyphsCore/GSInstance.h>

#include <sys/stat.h>

@protocol GSExportInstanceOperationProtocol <NSObject>
@required
@property (strong) GSFont *font;
@property (strong) GSInstance *instance;
- (NSString *)CIDShortRescoureName;
- (NSString *)CIDShortResourceName;
@optional
- (instancetype)initWithFont:(GSFont *)aFont instance:(GSInstance *)anInstance format:(int)aFormat;
@end

# pragma mark - G2/G3 comaptiblity

@interface GSExportInstanceOperation : NSOperation<GSExportInstanceOperationProtocol>
@end

static inline GSExportInstanceOperation * MakeGSExportInstanceOperation(GSFont *font, GSInstance *instance, int format) {
    GSExportInstanceOperation *operation = [NSClassFromString(@"GSExportInstanceOperation") alloc];
    if ([operation respondsToSelector:@selector(initWithFont:instance:format:)]) {
        operation = [operation initWithFont:font instance:instance format:format];
    } else {
        operation = [operation init];
        [operation setFont:font];
        [operation setInstance:instance];
    }
    return operation;
}

static inline NSString * MakePathForResource(NSString *resourcePath, NSString *ofType) {
    for (NSString *className in @[@"GSFont", @"GlyphsFileFormatOTF"]) {
        NSString *resolvedPath = [[NSBundle bundleForClass:NSClassFromString(className)] pathForResource:resourcePath ofType:ofType];
        if (resolvedPath) return resolvedPath;
    }
    return nil;
}

#pragma mark -

static BOOL REFGlyphNameResolverEnumerateLinesOfFileUsingBlock(NSString *aPath, NSStringEncoding anEncoding, void(^aBlock)(NSString *line, BOOL *stop), NSError **anError) {
    NSError *error = nil;
    NSData *data = [[NSData alloc] initWithContentsOfFile:aPath options:NSDataReadingMappedAlways error:&error];
    [[[NSString alloc] initWithData:data encoding:anEncoding] enumerateLinesUsingBlock:aBlock];
    if (error) {
        if (anError) *anError = error;
        return NO;
    }
    return YES;
}

@interface REFGlyphNameResolver () {
@private
    NSMutableDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *_mutableFromCIDGlyphNameToNiceNameDictionaries;
    NSMutableDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *_mutableFromNiceGlyphNameToCIDNameDictionaries;
}
@end

@implementation REFGlyphNameResolver

+ (instancetype)sharedResolver {
    static dispatch_once_t once;
    static REFGlyphNameResolver *sharedInstance = nil;
    dispatch_once(&once, ^{ sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (instancetype)init {
    if ((self = [super init])) {
        _mutableFromCIDGlyphNameToNiceNameDictionaries = [[NSMutableDictionary alloc] initWithCapacity:0];
        _mutableFromNiceGlyphNameToCIDNameDictionaries = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return self;
}

- (NSString *)CIDShortResourceNameForFont:(GSFont *)aFont {
    GSExportInstanceOperation *operation = MakeGSExportInstanceOperation(aFont, nil, 0);
    if ([operation respondsToSelector:@selector(CIDShortResourceName)])
        return [operation CIDShortResourceName];
    return [operation CIDShortRescoureName];
}

- (NSString *)CIDGlyphNameByConvertingFromNiceGlyphName:(NSString *)aString forFont:(GSFont *)aFont {
    @synchronized (self) {
        NSString *resourceName = [self CIDShortResourceNameForFont:aFont];
        [self prepareDictionariesWithCIDShortResourceNameIfNeeded:resourceName];
        return [[_mutableFromNiceGlyphNameToCIDNameDictionaries objectForKey:resourceName] objectForKey:aString];
    }
}

- (NSString *)niceGlyphNameByConvertingFromCIDGlyphName:(NSString *)aString forFont:(GSFont *)aFont {
    @synchronized (self) {
        NSString *resourceName = [self CIDShortResourceNameForFont:aFont];
        [self prepareDictionariesWithCIDShortResourceNameIfNeeded:resourceName];
        return [[_mutableFromCIDGlyphNameToNiceNameDictionaries objectForKey:resourceName] objectForKey:aString];
    }
}

- (void)prepareDictionariesWithCIDShortResourceNameIfNeeded:(NSString *)aCIDShortResourceName {
    if (aCIDShortResourceName) {
        @synchronized (self) {
            if ([_mutableFromCIDGlyphNameToNiceNameDictionaries objectForKey:aCIDShortResourceName] && [_mutableFromNiceGlyphNameToCIDNameDictionaries objectForKey:aCIDShortResourceName]) {
                return;
            }
        }
        NSString *path = MakePathForResource([NSString stringWithFormat:@"MapFile%@", aCIDShortResourceName], @"txt");
        if (path) {
            __block NSMutableDictionary<NSString *, NSString *> *mutableFromCIDGlyphNameToNiceGlyphNameDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
            __block NSMutableDictionary<NSString *, NSString *> *mutableFromNiceGlyphNameToCIDGlyphNameDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
            REFGlyphNameResolverEnumerateLinesOfFileUsingBlock(path, NSUTF8StringEncoding, ^(NSString *line, BOOL *stop) {
                NSArray<NSString *> *components = [line componentsSeparatedByString:@"\t"];
                if ([components count] >= 3) {
                    NSString *CIDGlyphName  = [NSString stringWithFormat:@"cid%05lu", [[components objectAtIndex:0] integerValue]];
                    NSString *niceGlyphName = [components objectAtIndex:1];
                    [mutableFromCIDGlyphNameToNiceGlyphNameDictionary setObject:niceGlyphName forKey:CIDGlyphName];
                    [mutableFromNiceGlyphNameToCIDGlyphNameDictionary setObject:CIDGlyphName forKey:niceGlyphName];
                }
            }, nil);
            @synchronized (self) {
                [_mutableFromCIDGlyphNameToNiceNameDictionaries setObject:[mutableFromCIDGlyphNameToNiceGlyphNameDictionary copy] forKey:aCIDShortResourceName];
                [_mutableFromNiceGlyphNameToCIDNameDictionaries setObject:[mutableFromNiceGlyphNameToCIDGlyphNameDictionary copy] forKey:aCIDShortResourceName];
            }
        }
    }
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

@end
