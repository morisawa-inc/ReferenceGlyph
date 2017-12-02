//
//  ReferenceGlyphPalettePlugin.h
//  ReferenceGlyph
//
//  Created by tfuji on 26/01/2016.
//  Copyright © 2016 Morisawa Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GlyphsCore/GlyphsPaletteProtocol.h>

@interface ReferenceGlyphPalettePlugin : NSObject <GlyphsPalette> {
    __unsafe_unretained NSView *_theView;
}
@property (nonatomic, assign) IBOutlet NSView *theView;
@end
