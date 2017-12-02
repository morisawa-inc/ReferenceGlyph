//
//  REFFontMenu.h
//  ReferenceGlyph
//
//  Created by tfuji on 03/12/2017.
//  Copyright © 2017 Morisawa Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "REFFontInstance.h"

@interface REFFontMenu : NSMenu <NSMenuDelegate>

@property (nonatomic) NSFont *selection;
@property (nonatomic, weak) NSPopUpButton<NSMenuDelegate> *popUpButton;

@end
