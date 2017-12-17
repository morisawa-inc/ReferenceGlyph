//
//  REFGlyphView.h
//  RefereneGlyph
//
//  Created by tfuji on 02/12/2017.
//  Copyright © 2017 Morisawa Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol REFGlyphViewDataSource;
@class GSFont;

@interface REFGlyphView : NSView

@property (nonatomic) NSString *glyphName;
@property (nonatomic) NSString *productionGlyphName;
@property (nonatomic) UTF32Char unicode;
@property (nonatomic) NSFont *font;
@property (nonatomic, weak) id<REFGlyphViewDataSource> dataSource;

@end

@protocol REFGlyphViewDataSource <NSObject>
- (GSFont *)currentGlyphsFontObjectForGlyphView:(REFGlyphView *)glyphView;
@end
