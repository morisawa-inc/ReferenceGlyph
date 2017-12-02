//
//  REFFontInstance.h
//  ReferenceGlyph
//
//  Created by tfuji on 03/12/2017.
//  Copyright © 2017 Morisawa Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface REFFontInstance : NSObject <NSCopying>

@property (nonatomic) NSString *postscriptName;
@property (nonatomic) NSString *familyName;
@property (nonatomic) NSString *styleName;
@property (nonatomic) NSUInteger weight;
@property (nonatomic) NSUInteger traits;

+ (NSArray<REFFontInstance *> *)availableInstancesOfFontFamily:(NSString *)aFontFamily;
- (instancetype)initWithArray:(NSArray *)anArray familyName:(NSString *)aFamilyName;

@end
