
#import "NVCDetailViewController.h"
#import "NVCApplicationDelegate.h"

@interface NVCDetailViewController () {
}

@end

#pragma mark -

@implementation NVCDetailViewController

#pragma mark Initializer

-(id) init {
	self = [super initWithNibName:nil bundle:nil];
	if (!self) {
		return nil;
	}
	self.hidesBottomBarWhenPushed = TRUE;
	return self;
}

#pragma mark UIViewController

-(void) loadView {
	[super loadView];
	self.title = @"Detail";
	self.view.backgroundColor = [UIColor darkGrayColor];
	if (NKUIDeviceUserIntefaceIdiom() == UIUserInterfaceIdiomPad) {
		self.navigationController.navigationBarHidden = TRUE;
		self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44.0)];
		self.toolbar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
		self.titleBarItem = [[[UIBarButtonItem alloc] initWithTitle:@"Title" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
		UIBarButtonItem *flexyBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[self.toolbar setItems:[NSArray arrayWithObjects:flexyBarItem, self.titleBarItem, flexyBarItem, nil]];
		[flexyBarItem release];
		[self.view addSubview:self.toolbar];
	}
}

-(void) viewDidLoad {
	[super viewDidLoad];
	if (NKUIDeviceUserIntefaceIdiom() == UIUserInterfaceIdiomPad) {
		UIBarButtonItem *masterButtonItem = [NKSplitViewNavigator splitViewNavigator].masterPopoverButtonItem;
		if (masterButtonItem != nil) {
			[self showMasterPopoverButtonItem:masterButtonItem];
		}
	}
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	NSDictionary *launchOptions = [NVCApplicationDelegate sharedApplicationDelegate].launchOptions;
	NSURL *launchURL			= [NVCApplicationDelegate sharedApplicationDelegate].launchURL;
	
	if (launchOptions || launchURL) {
		NSString *launchOptionDescription = nil;
		launchOptionDescription = [NSString stringWithFormat:@"Launch Options:\n%@\n", [launchOptions description]];
		
		NSString *launchURLDescription = nil;
		launchURLDescription	= [NSString stringWithFormat:@"Launch URL:\n%@\n", [launchURL description]];
		//self.textView.text		= [NSString stringWithFormat:@"%@%@", launchOptionDescription, launchURLDescription];
		NSLog(@"URL     = %@", launchURL);
		NSLog(@"Options = %@", launchOptions);
	}
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

-(void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return TRUE;
}


#pragma mark <NKSplitViewPopoverButtonDelegate>

-(void) showMasterPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
	if (NKUIDeviceUserIntefaceIdiom() == UIUserInterfaceIdiomPad) {
		NSMutableArray *itemsArray = [self.toolbar.items mutableCopy];
		[itemsArray insertObject:barButtonItem atIndex:0];
		[self.toolbar setItems:itemsArray animated:TRUE];
		[itemsArray release];
	}
}

-(void) invalidateMasterPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
	if (NKUIDeviceUserIntefaceIdiom() == UIUserInterfaceIdiomPad) {
		NSMutableArray *itemsArray = [self.toolbar.items mutableCopy];
		[itemsArray removeObject:barButtonItem];
		[self.toolbar setItems:itemsArray animated:TRUE];
		[itemsArray release];
	}
}


#pragma mark UIDocumentInteractionControllerDelegate

-(UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
	NSLog(@"%@", controller);
	return self;
}

-(UIView *) documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {
	NSLog(@"%@", controller);
	return self.view;
}


#pragma mark Gozer

-(void) didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void) viewDidUnload {
	self.toolbar = nil;
	self.documentItem = nil;
	self.documentInteractionController = nil;
	[super viewDidLoad];
}

-(void) dealloc {
	self.titleBarItem = nil;
	self.toolbar = nil;
	self.documentItem = nil;
	self.documentInteractionController = nil;
	[super dealloc];
}

@end
