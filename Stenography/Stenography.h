//
//  Stenography.h
//  Stenography
//
//  Created by Matthew Stallone on 2/28/17.
//  Copyright © 2017 Matthew Stallone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface Stenography : NSObject 

@property (nonatomic) NSBitmapImageRep *sourceBitmapRep;
@property (nonatomic) NSWindow *window;

- (id)initWithWindow:(NSWindow *)window;
- (void) setSource:(NSImage *)source;
- (NSImage *)encodeWithMessage:(NSString *)message;
- (NSString *)decode;

@end
