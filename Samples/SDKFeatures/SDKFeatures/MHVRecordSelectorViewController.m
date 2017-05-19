//
//  MHVRecordSelectorViewController.m
//  SDKFeatures
//
//  Created by Michael Burford on 5/18/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "MHVRecordSelectorViewController.h"
#import "MHVLib.h"
#import "MHVSodaConnectionProtocol.h"
#import "MHVConnectionFactory.h"
#import "MHVFeaturesConfiguration.h"
#import "MHVConnectionFactoryProtocol.h"
#import "MHVTypeListViewController.h"
#import "MHVPersonClientProtocol.h"

@interface MHVRecordSelectorViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) id<MHVSodaConnectionProtocol> connection;
@property (nonatomic, strong) NSCache *cache;

@end

@implementation MHVRecordSelectorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:[MHVFeaturesConfiguration configuration]];
    
    self.cache = [[NSCache alloc] init];

    self.navigationItem.title = NSLocalizedString(@"Select Person", @"Title to select person to view");
}

// -------------------------------------
//
// UITableViewDataSource & Delegate
//
// -------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.connection.personInfo.records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MHVRecordCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MHVRecordCell"];
    }
    
    MHVRecord *record = self.connection.personInfo.records[indexPath.row];
    
    cell.textLabel.text = record.displayName;
    
    cell.tag = indexPath.hash;
    
    // Cache, so don't have to reload image if it was already retrieved
    if ([self.cache objectForKey:record.ID])
    {
        cell.imageView.image = [self.cache objectForKey:record.ID];
    }
    else
    {
        [self.connection.personClient getPersonalImageWithRecordId:record.ID
                                                        completion:^(UIImage * _Nullable image, NSError * _Nullable error)
         {
             // Use tag to make sure cell hasn't been re-used
             [[NSOperationQueue mainQueue] addOperationWithBlock:^
              {
                  [self.cache setObject:image forKey:record.ID];
                  
                  if (image && cell.tag == indexPath.hash)
                  {
                      cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
                      cell.imageView.image = image;
                      [cell setNeedsUpdateConstraints];
                  }
              }];
         }];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MHVRecord *record = self.connection.personInfo.records[indexPath.row];
    
    self.connection.personInfo.selectedRecordID = record.ID;

    MHVTypeListViewController *typeListController = [[MHVTypeListViewController alloc] init];
    
    [self.navigationController pushViewController:typeListController animated:TRUE];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
