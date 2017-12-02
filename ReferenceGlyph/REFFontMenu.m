//
//  REFFontMenu.m
//  ReferenceGlyph
//
//  Created by tfuji on 03/12/2017.
//  Copyright © 2017 Morisawa Inc. All rights reserved.
//

#import "REFFontMenu.h"

static const char *REFFontMenuSelectionObservingContext = "REFFontMenuSelectionObservingContext";

@interface REFFontMenu () {
@private
    NSString *_familyName;
    NSArray<NSString *> *_availableFontFamilies;
    NSArray<REFFontInstance *> *_availableInstances;
    NSDictionary<NSString *, NSMutableSet<NSArray *> *> *_observerDictionary;
}
@end

@implementation REFFontMenu

+ (void)initialize {
    if ([self isKindOfClass:[REFFontMenu class]]) {
        [self exposeBinding:@"selection"];
    }
}

- (instancetype)init {
    if ((self = [super init])) {
        _selection = [NSFont fontWithName:@"Helvetica" size:[NSFont systemFontSize]]; // [NSFont systemFontOfSize:[NSFont systemFontSize]];
        _observerDictionary = @{
            @"selection": [[NSMutableSet alloc] initWithCapacity:0]
        };
        [self setDelegate:self];
    }
    return self;
}

- (instancetype)initWithFamilyName:(NSString *)aFamilyName {
    if ((self = [self init])) {
        _selection = nil;
        _familyName = aFamilyName;
    }
    return self;
}

- (void)setSelection:(NSFont *)selection {
    if (_selection != selection) {
        [self willChangeValueForKey:@"selection"];
        _selection = selection;
        [self didChangeValueForKey:@"selection"];
        for (NSArray *observer in _observerDictionary[@"selection"]) {
            [[observer[0] nonretainedObjectValue] setValue:selection forKeyPath:observer[1]];
        }
    }
}

- (IBAction)handleMenuItemAction:(NSMenuItem *)aMenuItem {
    REFFontInstance *instance = [aMenuItem representedObject];
    NSFont *font = [NSFont fontWithName:[instance postscriptName] size:[NSFont systemFontSize]];
    [self setSelection:font];
}

- (NSInteger)numberOfItemsInMenu:(NSMenu *)menu {
    if (_familyName) {
        _availableInstances = [REFFontInstance availableInstancesOfFontFamily:_familyName];
        return [_availableInstances count];
    }
    _availableFontFamilies = [[NSFontManager sharedFontManager] availableFontFamilies];
    if ([[_selection familyName] isEqualToString:@"Helvetica"]) {
        _availableFontFamilies = [_availableFontFamilies sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if ([obj1 isEqualToString:[_selection familyName]]) return NSOrderedAscending;
            if ([obj2 isEqualToString:[_selection familyName]]) return NSOrderedDescending;
            return [obj1 compare:obj2 options:0];
        }];
    }
    return [_availableFontFamilies count];
}

- (BOOL)menu:(NSMenu *)menu updateItem:(NSMenuItem *)item atIndex:(NSInteger)index shouldCancel:(BOOL)shouldCancel {
    if (_availableInstances) {
        NSFont *selection = [(REFFontMenu *)[menu supermenu] selection];
        REFFontInstance *instance = [_availableInstances objectAtIndex:index];
        [item setTitle:[instance styleName]];
        [item setState:[[selection fontName] isEqualToString:[instance postscriptName]] ? NSControlStateValueOn : NSControlStateValueOff];
        [item setAction:@selector(handleMenuItemAction:)];
        [item setTarget:[menu supermenu]];
        [item setRepresentedObject:instance];
        return YES;
    }
    NSString *familyName = [_availableFontFamilies objectAtIndex:index];
    NSMenu *submenu = [[[self class] alloc] initWithFamilyName:familyName];
    [item setTitle:familyName];
    [item setState:[[_selection familyName] isEqualToString:familyName] ? NSControlStateValueOn : NSControlStateValueOff];
    [item setSubmenu:submenu];
    return YES;
}

- (void)bind:(NSString *)binding toObject:(id)object withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
    if ([binding isEqualToString:@"selection"]) {
        [object addObserver:self forKeyPath:keyPath options:0 context:&REFFontMenuSelectionObservingContext];
        [_observerDictionary[@"selection"] addObject:@[[NSValue valueWithNonretainedObject:object], keyPath]];
    } else {
        [super bind:binding toObject:object withKeyPath:keyPath options:options];
    }
}

- (void)unbind:(NSString *)binding {
    if ([binding isEqualToString:@"selection"]) {
        for (NSArray *observer in _observerDictionary[binding]) {
            [[observer[0] nonretainedObjectValue] removeObserver:self forKeyPath:observer[1]];
        }
        [_observerDictionary[binding] removeAllObjects];
    } else{
        [super unbind:binding];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &REFFontMenuSelectionObservingContext) {
        id selection = [object valueForKeyPath:keyPath];
        [self setSelection:selection];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)menuWillOpen:(NSMenu *)menu {
    if ([_popUpButton respondsToSelector:@selector(menuWillOpen:)]) [_popUpButton menuWillOpen:menu];
}

- (void)menuDidClose:(NSMenu *)menu {
    if ([_popUpButton respondsToSelector:@selector(menuDidClose:)]) [_popUpButton menuDidClose:menu];
}

@end
