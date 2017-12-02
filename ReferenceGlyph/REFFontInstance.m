//
//  REFFontInstance.m
//  ReferenceGlyph
//
//  Created by tfuji on 03/12/2017.
//  Copyright © 2017 Morisawa Inc. All rights reserved.
//

#import "REFFontInstance.h"
#import <Cocoa/Cocoa.h>

@implementation REFFontInstance

+ (NSArray<REFFontInstance *> *)availableInstancesOfFontFamily:(NSString *)aFontFamily {
    NSMutableArray<REFFontInstance *> *mutableInstances = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSArray *member in [[NSFontManager sharedFontManager] availableMembersOfFontFamily:aFontFamily]) {
        [mutableInstances addObject:[[self alloc] initWithArray:member familyName:aFontFamily]];
    }
    return [mutableInstances copy];
}

- (instancetype)initWithArray:(NSArray *)anArray familyName:(NSString *)aFamilyName {
    if ((self = [self init])) {
        _postscriptName = [anArray objectAtIndex:0];
        _styleName = [anArray objectAtIndex:1];
        _weight = [[anArray objectAtIndex:2] unsignedIntegerValue];
        _traits = [[anArray objectAtIndex:3] unsignedIntegerValue];
        _familyName = aFamilyName;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

@end
