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
    // Select image via dialog
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowedFileTypes:[NSImage imageTypes]];
    [openPanel setTitle:@"Please choose your source image"];
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        NSImage *source = [[NSImage alloc] initWithContentsOfURL:[openPanel URL]];
        if (source != nil) {
            [engine setSource:source];
            [_sourceView setImage:source];
        }
    }];
}

- (IBAction)sourceDragged:(id)sender {
    // Select image via drag
    [engine setSource:_sourceView.image];
}

- (IBAction)saveOutput:(id)sender {
    // save the output image
    if (_outputView.image == nil)
        [self showAlertWithTitle:@"There is no image to save!" andMessage:@"Please encode a message into the source image to save the resulting file."];
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowsOtherFileTypes:NO];
    [savePanel setNameFieldStringValue:@"output.png"];
    
    [savePanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSBitmapImageRep *imgRep = [[((NSImage *)(_outputView.image)) representations] objectAtIndex: 0];
            NSData *data = [imgRep representationUsingType: NSPNGFileType properties: nil];
            [data writeToURL:[savePanel URL] atomically:YES];
        }
    }];
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    NSAlert *noOutputAlert = [[NSAlert alloc] init];
    [noOutputAlert setMessageText:title];
    [noOutputAlert setInformativeText:message];
    [noOutputAlert addButtonWithTitle:@"Close"];
    [noOutputAlert beginSheetModalForWindow:self.view.window completionHandler:nil];
}

- (IBAction)resetData:(id)sender {
    [engine setSource:nil];
    
    [_messageField setStringValue:@""];
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
