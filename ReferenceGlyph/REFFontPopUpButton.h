//
//  REFFontPopUpButton.h
//  ReferenceGlyph
//
//  Created by tfuji on 03/12/2017.
//  Copyright © 2017 Morisawa Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol REFFontPopUpButtonDelegate;

@interface REFFontPopUpButton : NSPopUpButton <NSMenuDelegate>

@property (nonatomic, weak) IBOutlet id<REFFontPopUpButtonDelegate> delegate;
@property (nonatomic) NSFont *selection;
@property (nonatomic) NSString *displayName;

@end

@protocol REFFontPopUpButtonDelegate <NSObject>
@optional
- (void)fontPopUpButton:(REFFontPopUpButton *)fontPopUpButton didChangeSelection:(NSFont *)font;
@end
