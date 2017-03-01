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
}

- (NSImage *)encodeWithMessage:(NSString *)message {
    const char *messageChar = [message UTF8String];
    size_t characters = strlen(messageChar);
    Boolean success = false;
    long lastPosition = -1;
    
    unsigned char *pixels = _sourceBitmapRep.bitmapData;
    
    // Check if image is valid
    if (_sourceBitmapRep.colorSpaceName == NULL || _sourceBitmapRep == nil) {
        NSAlert *noImageAlert = [[NSAlert alloc] init];
        [noImageAlert setMessageText:@"Image is corrupted or non existent!"];
        [noImageAlert setInformativeText:@"The image you provided is not a valid image. Please try a different source."];
        [noImageAlert addButtonWithTitle:@"Okay"];
        [noImageAlert runModal];
        
        return nil;
    }
    
    // So that there no need to truncate the message
    if (characters >= _sourceBitmapRep.pixelsWide * _sourceBitmapRep.pixelsHigh - 4) {
        NSAlert *tooLongAlert = [[NSAlert alloc] init];
        [tooLongAlert setMessageText:@"Your message is too long for the image!"];
        [tooLongAlert setInformativeText:@"Your message has to be truncated as it was too long to store in the image. The partial encoding is shown in the output image view."];
        [tooLongAlert addButtonWithTitle:@"Okay"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [tooLongAlert runModal];
        });
        
        return nil;
    }
    
    // Loop through all the pixels
    for (int row = 0; row < _sourceBitmapRep.pixelsHigh; row++) {
        long position = 0;
        for (int column = 0; column < _sourceBitmapRep.pixelsWide; column++) {
            // Get the current pixel location
            position = row*_sourceBitmapRep.pixelsHigh + column;
            
            // Check to see if the message is over
            if (position >= characters) {
                success = true;
                lastPosition = position;
                
                break;
            }
            
            @try {
                pixels[(position * 4) + 0] = ((pixels[(position * 4) + 0] & 0b11111100) | ((messageChar[position] & 0b11000000) >> 6)); // RED
                pixels[(position * 4) + 1] = ((pixels[(position * 4) + 1] & 0b11111100) | ((messageChar[position] & 0b00110000) >> 4)); // GREEN
                pixels[(position * 4) + 2] = ((pixels[(position * 4) + 2] & 0b11111100) | ((messageChar[position] & 0b00001100) >> 2)); // BLUE
                pixels[(position * 4) + 3] = ((pixels[(position * 4) + 3] & 0b11111100) | ((messageChar[position] & 0b00000011) >> 0)); // ALPHA
            } @catch (NSException *exception) {
                NSAlert *noImageAlert = [[NSAlert alloc] init];
                [noImageAlert setMessageText:@"Some memory in the image is unaccessible"];
                [noImageAlert setInformativeText:@"Please reload the program. Sorry!"];
                [noImageAlert addButtonWithTitle:@"Okay"];
                [noImageAlert runModal];
            }
        }
        if (success) break;
    }
    
    // Add a flag at the end of the message
    if (lastPosition != -1){
        for (long i = lastPosition; i < lastPosition + 4; i++) {
            pixels[(i * 4) + 0] = (pixels[(i * 4) + 0] & 0b11111100) | 0b00000010;
            pixels[(i * 4) + 1] = (pixels[(i * 4) + 1] & 0b11111100) | 0b00000001;
            pixels[(i * 4) + 2] = (pixels[(i * 4) + 2] & 0b11111100) | 0b00000010;
            pixels[(i * 4) + 3] = (pixels[(i * 4) + 3] & 0b11111100) | 0b00000011;
        }
    }
    
    // Create a new bitmap from the pixel data
    NSBitmapImageRep * imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&pixels pixelsWide:_sourceBitmapRep.pixelsWide pixelsHigh:_sourceBitmapRep.pixelsHigh bitsPerSample:_sourceBitmapRep.bitsPerSample samplesPerPixel:_sourceBitmapRep.samplesPerPixel hasAlpha:_sourceBitmapRep.hasAlpha isPlanar:_sourceBitmapRep.isPlanar colorSpaceName:_sourceBitmapRep.colorSpaceName bytesPerRow:_sourceBitmapRep.bytesPerRow bitsPerPixel:_sourceBitmapRep.bitsPerPixel];
    
    NSSize imageSize = NSMakeSize(CGImageGetWidth([imageRep CGImage]), CGImageGetHeight([imageRep CGImage]));
    
    // Make new image from the bitmap
    NSImage * image = [[NSImage alloc] initWithSize:imageSize];
    [image addRepresentation:imageRep];
    
    return image;
}

- (NSString *)decode {
    int position = 0;
    unsigned char *pixels = _sourceBitmapRep.bitmapData;
    Boolean done = false;
    
    NSMutableString *message = [NSMutableString string];
    
    for (int row = 0; row < _sourceBitmapRep.pixelsHigh; row++) {
        for (int column = 0; column < _sourceBitmapRep.pixelsWide; column++) {
            if (position >= _sourceBitmapRep.pixelsHigh*_sourceBitmapRep.pixelsWide) break;
            
            // get the letter
            char letter = ((pixels[(position * 4) + 0] & 0b00000011) << 6) |
                          ((pixels[(position * 4) + 1] & 0b00000011) << 4) |
                          ((pixels[(position * 4) + 2] & 0b00000011) << 2) |
                          ((pixels[(position * 4) + 3] & 0b00000011) << 0);
            [message appendFormat:@"%c", letter];
            
            // Check for end of message flag
            if ([[message substringFromIndex:MAX((int)[message length]-4, 0)] isEqual: [NSString stringWithFormat:@"%c%c%c%c", 155, 155, 155, 155]]) {
                done = true;
                break;
            }
            
            position++;
        }
        if (done) break;
    }
    
    return message;
}

@end
