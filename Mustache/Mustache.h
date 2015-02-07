//
//  Mustache.h
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for Mustache.
FOUNDATION_EXPORT double MustacheVersionNumber;

//! Project version string for Mustache.
FOUNDATION_EXPORT const unsigned char MustacheVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Mustache/PublicHeader.h>

// Caveat
//
// This one should be private, but Xcode today requires ObjC headers that should
// be available to private Swift code to be public.
#import "GRMustacheKeyAccess_private.h"
