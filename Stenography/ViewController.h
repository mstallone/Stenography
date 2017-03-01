//
//  ViewController.h
//  Stenography
//
//  Created by Matthew Stallone on 2/28/17.
//  Copyright © 2017 Matthew Stallone. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Stenography.h"

@interface ViewController : NSViewController {
    Stenography *engine;
}

@property (weak) IBOutlet NSImageView *sourceView;
@property (weak) IBOutlet NSImageView *outputView;
@property (weak) IBOutlet NSTextField *messageField;

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;

- (IBAction)chooseSource:(id)sender;
- (IBAction)sourceDragged:(id)sender;
- (IBAction)saveOutput:(id)sender;
- (IBAction)resetData:(id)sender;

- (IBAction)encode:(id)sender;
- (IBAction)decode:(id)sender;

@end
