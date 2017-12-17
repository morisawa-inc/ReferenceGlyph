//
//  REFGlyphNameResolver.h
//  ReferenceGlyph
//
//  Created by tfuji on 17/12/2017.
//  Copyright © 2017 Morisawa Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GlyphsCore/GSFont.h>

@interface REFGlyphNameResolver : NSObject <NSCopying>

+ (instancetype)sharedResolver;
- (NSString *)CIDGlyphNameByConvertingFromNiceGlyphName:(NSString *)aString forFont:(GSFont *)aFont;
- (NSString *)niceGlyphNameByConvertingFromCIDGlyphName:(NSString *)aString forFont:(GSFont *)aFont;

@end
