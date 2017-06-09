//
//  ViewController.m
//  TestSandbox
//
//  Created by yiqiwang(王一棋) on 2017/6/7.
//  Copyright © 2017年 melody5417. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSTableViewDelegate, NSTableViewDataSource, NSOpenSavePanelDelegate>
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSButton *openButton;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReceiveNotification:)
                                                 name:@"NotificationChangeNewDir"
                                               object:nil];
}


- (IBAction)onOpen:(id)sender {
    NSString *picStr = NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES).firstObject;
    picStr = [picStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:picStr];


    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setDelegate:self];
    [openPanel setDirectoryURL:url];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanSelectHiddenExtension:YES];
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationChangeNewDir"
                                                                    object:self
                                                                  userInfo:@{@"URL":openPanel.URL}];
            });
        }
    }];

}

#pragma mark - notification

- (void)handleReceiveNotification:(NSNotification *)nc {
    NSDictionary *userInfo = nc.userInfo;
    if (userInfo.count < 1) {
        return ;
    }

    NSURL *url = [userInfo objectForKey:@"URL"];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:url.path error:nil];
    if (contents.count > 0) {
        self.dataSource = [contents mutableCopy];
        [self.tableView reloadData];
    }
}

#pragma mark - tableview

#pragma mark - NSTableViewDelegate

- (nullable NSView *)tableView:(NSTableView *)tableView
            viewForTableColumn:(nullable NSTableColumn *)tableColumn
                           row:(NSInteger)row {
    NSTextField *textfield = [[NSTextField alloc] initWithFrame:NSZeroRect];
    textfield.stringValue = [self.dataSource objectAtIndex:row];
    return textfield;
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.dataSource.count;
}

- (nullable id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(nullable NSTableColumn *)tableColumn
                     row:(NSInteger)row {
    return [self.dataSource objectAtIndex:row];
}

#pragma mark - NSOpenSavePanelDelegate

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
    NSString * fileExtension = [url pathExtension];
    if (([fileExtension  isEqual: @""])
        || ([fileExtension  isEqual: @"/"])
        || (fileExtension == nil)) {
        return NO;
    }
    return [@[@"photoslibrary"] containsObject:[fileExtension lowercaseString]];
};

@end
