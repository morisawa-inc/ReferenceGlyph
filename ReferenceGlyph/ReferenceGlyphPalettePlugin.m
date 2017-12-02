//
//  ReferenceGlyphPalettePlugin.m
//  ReferenceGlyph
//
//  Created by tfuji on 26/01/2016.
//  Copyright © 2016 Morisawa Inc. All rights reserved.
//

#import "ReferenceGlyphPalettePlugin.h"
#import <GlyphsCore/GlyphsCore.h>
#import <GlyphsCore/GSGlyph.h>
#import <GlyphsCore/GSLayer.h>
#import <GlyphsCore/GSWindowControllerProtocol.h>
#import "REFGlyphView.h"
#import "REFFontPopUpButton.h"

static inline NSString * REFLocalizedString(NSString *key, NSString *comment) {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[ReferenceGlyphPalettePlugin class]] pathForResource:@"Localizable" ofType:@"strings"]];
    return bundle ? NSLocalizedStringFromTableInBundle(key, nil, bundle, comment) : NSLocalizedString(key, comment);
}

@interface NSApplication (GSDocument)
- (NSDocument *)currentFontDocument;
@end

@interface ReferenceGlyphPalettePlugin ()
@property (nonatomic) IBOutlet REFGlyphView *glyphView;
@property (weak) IBOutlet REFFontPopUpButton *popupButton;
@property (nonatomic) NSFont *font;
@end

@implementation ReferenceGlyphPalettePlugin

@synthesize windowController;

- (id)init {
	if ((self = [super init])) {
        [[NSBundle bundleForClass:[self class]] loadNibNamed:@"REFPaletteView" owner:self topLevelObjects:nil];
	}
	return self;
}

- (NSFont *)defaultFont {
    for (NSString *fontName in @[@"RyuminPr6N-Reg", @"KozMinPr6N-Regular", @"KozGoPr6N-Regular", @"Helvetica"]) {
        NSFont *font = [NSFont fontWithName:fontName size:0.0];
        if (font) return font;
    }
    return [NSFont systemFontOfSize:0.0];
}

- (void)awakeFromNib {
    [_popupButton setSelection:[self defaultFont]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidUpdateInterface:) name:@"GSUpdateInterface" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSUInteger)interfaceVersion {
	return 1;
}

- (GSLayer *)layer {
    return [[self windowController] activeLayer];
}

- (NSString *)title {
    return REFLocalizedString(@"Reference Glyph", nil);
}

- (NSInteger)maxHeight {
    return 174;
}

- (NSInteger)minHeight {
    return 174;
}

- (void)applicationDidUpdateInterface:(NSNotificationCenter *)notification {
    GSLayer *layer = [self layer];
    if (layer) {
        GSGlyph *glyph = [layer parent];
        [_glyphView setUnicode:[glyph unicodeChar]];
        NSString *baseGlyphName = [[[glyph name] componentsSeparatedByString:@"."] firstObject];
        if ([[[NSRegularExpression alloc] initWithPattern:@"^cid[0-9]{5}$" options:0 error:nil] rangeOfFirstMatchInString:baseGlyphName options:0 range:NSMakeRange(0, [baseGlyphName length])].location != NSNotFound) {
            [_glyphView setGlyphName:baseGlyphName];
        } else {
            [_glyphView setGlyphName:[glyph production]];
        }
    } else {
        [_glyphView setUnicode:0];
        [_glyphView setGlyphName:nil];
    }
}

- (void)fontPopUpButton:(REFFontPopUpButton *)fontPopUpButton didChangeSelection:(NSFont *)font {
    [_glyphView setFont:font];
}

@end
