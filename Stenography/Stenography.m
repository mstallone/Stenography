//
//  Stenography.m
//  Stenography
//
//  Created by Matthew Stallone on 2/28/17.
//  Copyright © 2017 Matthew Stallone. All rights reserved.
//

#import "Stenography.h"

@implementation Stenography

- (id)initWithWindow:(NSWindow *)window {
    if (self = [super init]) {
        _window = window;
    }
    return self;
}

- (void) setSource:(NSImage *)source {
    _sourceBitmapRep = [[NSBitmapImageRep alloc] initWithData:[source TIFFRepresentation]];
    
    pixelsWide = _sourceBitmapRep.pixelsWide;
    pixelsHigh = _sourceBitmapRep.pixelsHigh;
    pixels = _sourceBitmapRep.bitmapData;
}

- (NSImage *)encodeWithMessage:(NSString *)message {
    const char *messageChar = [message UTF8String];
    size_t characters = strlen(messageChar);
    int position = 0;
    
    for (int row = 0; row < pixelsHigh; row++) {
        unsigned char *rowPosition = row*_sourceBitmapRep.bytesPerRow + pixels;
        for (int column = 0; column < pixelsWide; column++) {
            if (position >= characters) break;
            
            pixels[(position * 4) + 0] = ((*rowPosition++ >> 2) << 2) | ((messageChar[position] & 192) >> 6); // RED
            pixels[(position * 4) + 1] = ((*rowPosition++ >> 2) << 2) | ((messageChar[position] &  48) >> 4); // GREEN
            pixels[(position * 4) + 2] = ((*rowPosition++ >> 2) << 2) | ((messageChar[position] &  12) >> 2); // BLUE
            pixels[(position * 4) + 3] = ((*rowPosition++ >> 2) << 2) | ((messageChar[position] &   3) >> 0); // ALPHA

            position++;
        }
        if (position >= characters) break;
    }

    NSBitmapImageRep *output = [NSBitmapImageRep imageRepWithData:[NSData dataWithBytes:pixels length:pixelsWide*pixelsHigh]];
    return [[NSImage alloc] initWithCGImage:[output CGImage] size:NSMakeSize(pixelsWide, pixelsHigh)];
}

- (NSString *)decode {
    return nil;
}

@end
