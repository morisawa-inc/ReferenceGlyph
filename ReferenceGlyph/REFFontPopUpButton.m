//
//  REFFontPopUpButton.m
//  ReferenceGlyph
//
//  Created by tfuji on 03/12/2017.
//  Copyright © 2017 Morisawa Inc. All rights reserved.
//

#import "REFFontPopUpButton.h"
#import "REFFontMenu.h"

@implementation REFFontPopUpButton

- (instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self removeAllItems];
        REFFontMenu *menu = [[REFFontMenu alloc] init];
        [self setMenu:menu];
        [menu setPopUpButton:self];
        [menu bind:@"selection" toObject:self withKeyPath:@"selection" options:nil];
        [self bind:@"selectedValue" toObject:self withKeyPath:@"displayName" options:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillPopUpNotification:) name:NSPopUpButtonWillPopUpNotification object:self];
        [self setSelection:[menu selection]];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)buttonFrame pullsDown:(BOOL)flag {
    if ((self = [super initWithFrame:buttonFrame pullsDown:flag])) {
        [self removeAllItems];
        REFFontMenu *menu = [[REFFontMenu alloc] init];
        [self setMenu:menu];
        [menu setPopUpButton:self];
        [menu bind:@"selection" toObject:self withKeyPath:@"selection" options:nil];
        [self bind:@"selectedValue" toObject:self withKeyPath:@"displayName" options:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillPopUpNotification:) name:NSPopUpButtonWillPopUpNotification object:self];
        [self setSelection:[menu selection]];
    }
    return self;
}

- (void)dealloc {
    [[self menu] unbind:@"selection"];
    [self unbind:@"selectedValue"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSPopUpButtonWillPopUpNotification object:self];
}

- (void)setSelection:(NSFont *)selection {
    if (_selection != selection) {
        [self willChangeValueForKey:@"selection"];
        _selection = selection;
        [self didChangeValueForKey:@"selection"];
        [self setDisplayName:[selection displayName]];
        if ([_delegate respondsToSelector:@selector(fontPopUpButton:didChangeSelection:)]) {
            [_delegate fontPopUpButton:self didChangeSelection:selection];
        }
    }
}

- (void)handleWillPopUpNotification:(NSNotification *)notification {
    [self selectItemWithTitle:[_selection familyName]];
    [self setDisplayName:[_selection familyName]];
}

- (void)menuWillOpen:(NSMenu *)menu {
    [self setDisplayName:[_selection displayName]];
}

- (void)menuDidClose:(NSMenu *)menu {
    return;
}

@end

