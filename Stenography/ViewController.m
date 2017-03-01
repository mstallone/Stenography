//
//  ViewController.m
//  Stenography
//
//  Created by Matthew Stallone on 2/28/17.
//  Copyright © 2017 Matthew Stallone. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    engine = [[Stenography alloc] initWithWindow:self.view.window];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)chooseSource:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowedFileTypes:[NSImage imageTypes]];
    [openPanel setTitle:@"Please choose your source image"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [openPanel runModal];
        
        NSImage *source = [[NSImage alloc] initWithContentsOfURL:[openPanel URL]];
        if (source != nil) {
            [engine setSource:source];
            [_sourceView setImage:source];
        }
    });
}

- (IBAction)sourceDragged:(id)sender {
    [engine setSource:_sourceView.image];
}

- (IBAction)saveOutput:(id)sender {
    if (_outputView.image == nil) {
        NSAlert *noOutputAlert = [[NSAlert alloc] init];
        [noOutputAlert setMessageText:@"There is no image to save!"];
        [noOutputAlert setInformativeText:@"Please encode a message into the source image to save the resulting file."];
        [noOutputAlert addButtonWithTitle:@"Close"];
        [noOutputAlert beginSheetModalForWindow:self.view.window completionHandler:nil];
    }
    
    //TODO
}

- (IBAction)resetData:(id)sender {
    [engine setSource:nil];
    
    _outputView.image = nil;
    _sourceView.image = nil;
}

- (IBAction)encode:(id)sender {
    _outputView.image = [engine encodeWithMessage:[_messageField stringValue]];
}

- (IBAction)decode:(id)sender {
    [_messageField setStringValue:[engine decode]];
}

@end
