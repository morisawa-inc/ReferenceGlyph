//
//  REFGlyphView.h
//  RefereneGlyph
//
//  Created by tfuji on 02/12/2017.
//  Copyright © 2017 Morisawa Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface REFGlyphView : NSView

@property (nonatomic) NSString *glyphName;
@property (nonatomic) UTF32Char unicode;
@property (nonatomic) NSFont *font;

@end

