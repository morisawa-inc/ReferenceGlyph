//
//  REFGlyphView.m
//  ReferenceGlyph
//
//  Created by tfuji on 02/12/2017.
//  Copyright © 2017 Morisawa Inc. All rights reserved.
//

#import "REFGlyphView.h"
#import "REFGlyphNameResolver.h"

static inline CGGlyph REGGlyphViewGetGlyphFromUnicodeChar(UTF32Char unicode, CTFontRef font) {
    CGGlyph glyph = 0;
    NSString *character = [[NSString alloc] initWithBytes:&unicode length:sizeof(unicode) encoding:NSUTF32LittleEndianStringEncoding];
    NSData *data = [character dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
    NSUInteger numberOfCharacters = [data length] / sizeof(UniChar);
    CGGlyph *glyphs = malloc(numberOfCharacters * sizeof(CGGlyph));
    if (CTFontGetGlyphsForCharacters(font, [data bytes], glyphs, numberOfCharacters)) {
        glyph = glyphs[0];
    }
    free(glyphs);
    return glyph;
}

@implementation REFGlyphView

- (void)setGlyphName:(NSString *)aGlyphName {
    if (_glyphName != aGlyphName) {
        _glyphName = aGlyphName;
        [self setNeedsDisplayInRect:[self bounds]];
    }
}

- (void)setProductionGlyphName:(NSString *)aProductionGlyphName {
    if (_productionGlyphName != aProductionGlyphName) {
        _productionGlyphName = aProductionGlyphName;
        [self setNeedsDisplayInRect:[self bounds]];
    }
}

- (void)setUnicode:(UTF32Char)anUnicode {
    if (_unicode != anUnicode) {
        _unicode = anUnicode;
        [self setNeedsDisplayInRect:[self bounds]];
    }
}

- (void)setFont:(NSFont *)aFont {
    if (_font != aFont) {
        _font = aFont;
        [self setNeedsDisplayInRect:[self bounds]];
    }
}

- (CGFloat)scale {
    return 0.75;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if ((_glyphName || _unicode > 0) && _font) {
        NSRect bounds = [self bounds];
        CGFloat scale = [self scale];
        CGFloat fontSize = bounds.size.height * scale;
        CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
        CGContextSaveGState(context);
        
        CGFontRef font = CGFontCreateWithFontName((CFStringRef)[_font fontName]);
        CGContextSetFont(context, font);
        CGContextSetFontSize(context, fontSize);
        
        CGGlyph glyph = 0;
        if (glyph == 0 && _unicode > 0) glyph = REGGlyphViewGetGlyphFromUnicodeChar(_unicode, (__bridge CTFontRef)_font);
        if (glyph == 0 && _productionGlyphName) glyph = CGFontGetGlyphWithGlyphName(font, (CFStringRef)_productionGlyphName);
        if (glyph == 0 && _glyphName) {
            if ([_dataSource respondsToSelector:@selector(currentGlyphsFontObjectForGlyphView:)]) {
                GSFont *glyphsFont = [_dataSource currentGlyphsFontObjectForGlyphView:self];
                NSString *alternativeGlyphName = ([_glyphName hasPrefix:@"cid"]) ? [[REFGlyphNameResolver sharedResolver] niceGlyphNameByConvertingFromCIDGlyphName:_glyphName forFont:glyphsFont] : [[REFGlyphNameResolver sharedResolver] CIDGlyphNameByConvertingFromNiceGlyphName:_glyphName forFont:glyphsFont];
                if (alternativeGlyphName) glyph = CGFontGetGlyphWithGlyphName(font, (CFStringRef)alternativeGlyphName);
            }
            if (glyph == 0) glyph = CGFontGetGlyphWithGlyphName(font, (CFStringRef)_glyphName);
        }
        
        int advance = 0;
        CGFontGetGlyphAdvances(font, &glyph, 1, &advance);
        
        CGRect frame = CGRectMake(0.0, 0.0, (CGFloat)advance * (fontSize / CGFontGetUnitsPerEm(font)), bounds.size.height * scale);
        frame.origin = NSMakePoint((bounds.size.width - frame.size.width) / 2.0, (bounds.size.height- frame.size.height) / 2.0);
        CGPoint baselines[2] = {
            CGPointMake(frame.origin.x, frame.origin.y + frame.size.height * -CGFontGetDescent(font) / CGFontGetUnitsPerEm(font)),
            CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height * -CGFontGetDescent(font) / CGFontGetUnitsPerEm(font))
        };
        CGContextStrokeLineSegments(context, baselines, 2);
        CGContextSetRGBStrokeColor(context, 0.0, 0.68, 0.937, 1.0);
        CGContextStrokeRect(context, frame);
        
        CGPoint position = CGPointMake(0.0, -CGFontGetDescent(font) * (fontSize / CGFontGetUnitsPerEm(font)));
        position.x += (bounds.size.width - ((CGFloat)advance * (fontSize / CGFontGetUnitsPerEm(font)))) / 2.0;
        position.y += (bounds.size.height - ((CGFloat)CGFontGetUnitsPerEm(font) * (fontSize / CGFontGetUnitsPerEm(font)))) / 2.0;
        CGContextSetTextDrawingMode(context, kCGTextFill);
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextSetTextPosition(context, 0, 0);
        CGContextSetFillColorWithColor(context, [[NSColor textColor] CGColor]);
        CGContextShowGlyphsAtPositions(context, &glyph, &position, 1);
        CGFontRelease(font);
        CGContextRestoreGState(context);
    }
}

@end

