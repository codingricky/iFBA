//
//  OptiCadeViewController.m
//  iFBA
//
//  Created by Yohann Magnien on 28/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OptiCadeViewController.h"
#import "BTstack/BTstackManager.h"
#import "BTstack/BTDiscoveryViewController.h"
#import "BTstackManager.h"
#import "OptConGetiCadeViewController.h"
#import "fbaconf.h"

char iCade_langStr[MAX_LANG][32]={
    "English",
    "Français"
};
int mOptICadeButtonSelected;
extern volatile int emuThread_running;
extern int launchGame;
extern char gameName[64];


@implementation OptiCadeViewController
@synthesize tabView,btn_backToEmu;
@synthesize optgetButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title=NSLocalizedString(@"iCade",@"");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //
    // Change the properties of the imageView and tableView (these could be set
    // in interface builder instead).
    //
    //self.tabView.style=UITableViewStyleGrouped;
    optgetButton=[[OptConGetiCadeViewController alloc] initWithNibName:@"OptConGetiCadeViewController" bundle:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [optgetButton release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BTstackManager *bt = [BTstackManager sharedInstance];
    if (ifba_conf.btstack_on&&bt) {
        UIAlertView *aboutMsg=[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",@"") message:NSLocalizedString(@"Warning iCade BTStack",@"") delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil] autorelease];
        [aboutMsg show];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (emuThread_running) {
        btn_backToEmu.title=[NSString stringWithFormat:@"%s",gameName];
        self.navigationItem.rightBarButtonItem = btn_backToEmu;
    }    
    [tabView reloadData];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section==1) return VSTICK_NB_BUTTON;
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title=nil;
    return title;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *footer=nil;
    switch (section) {
        case 0://Language
            footer=NSLocalizedString(@"iCade Language",@"");
            break;
        case 1://Mapping
            footer=NSLocalizedString(@"Mapping info",@"");
            break;
        case 2://Reset to Default
            footer=@"";
            break;
    }
    return footer;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UILabel *lblview;
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];                
    }
    cell.accessoryType=UITableViewCellAccessoryNone;
    switch (indexPath.section) {
        case 0://Reset to default
            cell.textLabel.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"System keyboard: ",@""),[NSString stringWithCString:iCade_langStr[ifba_conf.icade_lang] encoding:NSUTF8StringEncoding]];
            cell.textLabel.textAlignment=UITextAlignmentLeft;
            cell.accessoryView=nil;
            break;
        case 1://Mapping
            cell.textLabel.text=[NSString stringWithFormat:@"%s",joymap_iCade[indexPath.row].btn_name];
            lblview=[[UILabel alloc] initWithFrame:CGRectMake(0,0,100,30)];
            if (joymap_iCade[indexPath.row].dev_btn) lblview.text=[NSString stringWithFormat:@"Button %c",'A'-1+joymap_iCade[indexPath.row].dev_btn];
            else lblview.text=@"/";
            lblview.backgroundColor=[UIColor clearColor];
            cell.accessoryView=lblview;
            [lblview release];
            cell.textLabel.textAlignment=UITextAlignmentLeft;
            break;
        case 2://Reset to default
            cell.textLabel.text=NSLocalizedString(@"Reset to default",@"");
            cell.textLabel.textAlignment=UITextAlignmentCenter;
            cell.accessoryView=nil;
            break;
    }
    
	
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            ifba_conf.icade_lang++;
            if (ifba_conf.icade_lang==MAX_LANG) ifba_conf.icade_lang=0;
            [tableView reloadData];
            break;
        case 1:
            mOptICadeButtonSelected=indexPath.row;
            [self presentSemiModalViewController:optgetButton];
            [tabView reloadData];            
            break;
        case 2:
            joymap_iCade[0].dev_btn=4;//Start
            joymap_iCade[1].dev_btn=8;//Select/Coin
            joymap_iCade[2].dev_btn=0;//Menu
            joymap_iCade[3].dev_btn=0;//Turbo
            joymap_iCade[4].dev_btn=0;//Service
            joymap_iCade[5].dev_btn=1;//Fire 1
            joymap_iCade[6].dev_btn=2;//Fire 2
            joymap_iCade[7].dev_btn=3;//...
            joymap_iCade[8].dev_btn=5;//
            joymap_iCade[9].dev_btn=6;//
            joymap_iCade[10].dev_btn=7;//Fire 6
            [tabView reloadData];            
            break;
    }
}


-(IBAction) backToEmu {
    launchGame=2;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

@end
