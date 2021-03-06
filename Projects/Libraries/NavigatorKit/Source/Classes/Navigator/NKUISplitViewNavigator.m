
#import <NavigatorKit/NKUISplitViewNavigator.h>
#import <NavigatorKit/NKNavigator+Internal.h>

#import <NavigatorKit/NKSplitViewPopoverButtonDelegate.h>
#import <NavigatorKit/NKNavigatorAction.h>
#import <NavigatorKit/NKNavigatorMap.h>
#import <NavigatorKit/NKNavigationController.h>

#import <NavigatorKit/UIApplication+NKNavigator.h>
#import <NavigatorKit/UISplitViewController+NKNavigator.h>

@implementation NKUISplitViewNavigator

@synthesize navigators;
@synthesize popoverController;
@synthesize masterPopoverButtonItem;
@synthesize masterPopoverButtonTitle;

#pragma mark Shared Constructor

+(NKUISplitViewNavigator *) UISplitViewNavigator {
	if (![UIApplication sharedApplication].applicationNavigator) {
		[UIApplication sharedApplication].applicationNavigator = [[[self class] alloc] init];
	}
	return (NKUISplitViewNavigator *)[UIApplication sharedApplication].applicationNavigator;
}

#pragma mark Initializers

-(id) init {
	self = [super init];
	if (!self) {
		return nil;
	}
	NSMutableArray *mutableNavigators = [[NSMutableArray alloc] initWithCapacity:2];
	for (NSUInteger index = 0; index < 2; ++index) {
		NKNavigator *navigator		= [[NKNavigator alloc] init];
		navigator.parentNavigator	= self;
		navigator.window			= self.window;
		navigator.uniquePrefix		= [NSString stringWithFormat:@"NKUISplitViewNavigator%d", index];
		[mutableNavigators addObject:navigator];
		[navigator release];
	}
	self.navigators = mutableNavigators;
	return self;
}


#pragma mark API

-(void) setViewControllersWithNavigationURLs:(NSArray *)aURLArray {
	NSUInteger count				= [self.navigators count];
	NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:count];
	for (NSUInteger currentIndex = 0; currentIndex < count; ++currentIndex) {
		NKNavigator *navigator = [self navigatorAtIndex:currentIndex];
		[navigator openNavigatorAction:[NKNavigatorAction actionWithNavigatorURLPath:[aURLArray objectAtIndex:currentIndex]]];
		[viewControllers addObject:navigator.rootViewController];
	}
	self.splitViewController.viewControllers = viewControllers;
	[viewControllers release]; viewControllers = nil;
}

-(NKNavigator *) masterNavigator {
	return [self navigatorAtIndex:NKSplitViewMasterNavigator];
}

-(NKNavigator *) detailNavigator {
	return [self navigatorAtIndex:NKSplitViewDetailNavigator];
}

-(NKNavigator *) navigatorAtIndex:(NKSplitNavigatorPosition)anIndex {
	NSAssert(anIndex >= 0 && anIndex <= 1, @"");
	return [navigators objectAtIndex:anIndex];
}

-(NKNavigator *) navigatorForURLPath:(NSString *)aURLPath {
	for (NKNavigator *navigator in self.navigators) {
		if ([navigator.navigationMap isURLPathSupported:aURLPath]) {
			return navigator;
		}
	}
	if ([self.navigationMap isURLPathSupported:aURLPath]) {
		return self;
	}
	return nil;
}

-(void) navigator:(NKNavigator *)navigator didDisplayController:(UIViewController *)controller {
	NSUInteger navigatorIndex = [self.navigators indexOfObject:navigator];
	if (navigatorIndex == NSNotFound) {
		return;
	}
	
	if (controller == self.splitViewController) {
		if ([self.splitViewController.viewControllers objectAtIndex:navigatorIndex] != controller) {
			NSMutableArray *viewControllers = [self.splitViewController.viewControllers mutableCopy];
			[viewControllers replaceObjectAtIndex:navigatorIndex withObject:controller];
			self.splitViewController.viewControllers = viewControllers;
		}
	}
	
	if (navigatorIndex == NKSplitViewDetailNavigator) {

	}
	
	if (navigatorIndex == NKSplitViewMasterNavigator) {
	}
}


#pragma mark <UISplitViewControllerDelegate>

-(UISplitViewController *) splitViewController {
	if ([super rootViewController] != nil) {
		return (UISplitViewController *)[super rootViewController];
	}
	
	UISplitViewController *rootSplitViewController = [[UISplitViewController alloc] init];
	rootSplitViewController.delegate = self;
	[self setRootViewController:rootSplitViewController];
	[rootSplitViewController release];
	
	return (UISplitViewController *)[self rootViewController];
}

-(void) splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
	self.popoverController = pc;
	self.popoverController.delegate = self;
	self.masterPopoverButtonItem = barButtonItem;
	UIViewController *rightDetailController = self.splitViewController.detailViewController;
	BOOL isDetailNavigationController = [rightDetailController isKindOfClass:[UINavigationController class]];
	if (isDetailNavigationController) {
		UINavigationController *detailNavigationController = (UINavigationController *)rightDetailController;
		BOOL confirmsToDetail = [[(UINavigationController *)detailNavigationController topViewController] conformsToProtocol:@protocol(NKSplitViewPopoverButtonDelegate)];			
		if (confirmsToDetail) {
			UIViewController <NKSplitViewPopoverButtonDelegate> *controller = detailNavigationController.topViewController;
			if (controller && barButtonItem) {
				if (!self.masterPopoverButtonItem.title) {
					self.masterPopoverButtonItem.title = (controller.title == nil) ? controller.title : @"Master";
				}
				if ([controller respondsToSelector:@selector(showMasterPopoverButtonItem:)]) {
					[controller showMasterPopoverButtonItem:self.masterPopoverButtonItem];
				}
			}
		}
	}
	else {
		BOOL confirmsToDetail = [rightDetailController conformsToProtocol:@protocol(NKSplitViewPopoverButtonDelegate)];			
		if (confirmsToDetail) {
			UIViewController <NKSplitViewPopoverButtonDelegate> *controller = rightDetailController;
			if (controller && barButtonItem) {
				if (!self.masterPopoverButtonItem.title) {
					self.masterPopoverButtonItem.title = (controller.title == nil) ? controller.title : @"Master";
				}
				if ([controller respondsToSelector:@selector(showMasterPopoverButtonItem:)]) {
					[controller showMasterPopoverButtonItem:self.masterPopoverButtonItem];
				}
			}
		}
	}
}

-(void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	UIViewController *rightDetailController = self.splitViewController.detailViewController;
	BOOL isDetailNavigationController = [rightDetailController isKindOfClass:[UINavigationController class]];
	if (isDetailNavigationController) {
		UINavigationController *detailNavigationController = (UINavigationController *)rightDetailController;
		BOOL confirmsToDetail = [[(UINavigationController *)detailNavigationController topViewController] conformsToProtocol:@protocol(NKSplitViewPopoverButtonDelegate)];			
		if (confirmsToDetail) {
			UIViewController <NKSplitViewPopoverButtonDelegate> *controller = detailNavigationController.topViewController;
			if (controller && barButtonItem) {
				if ([controller respondsToSelector:@selector(invalidateMasterPopoverButtonItem:)]) {
					[controller invalidateMasterPopoverButtonItem:self.masterPopoverButtonItem];
				}
			}
		}
	}
	else {
		BOOL confirmsToDetail = [rightDetailController conformsToProtocol:@protocol(NKSplitViewPopoverButtonDelegate)];			
		if (confirmsToDetail) {
			UIViewController <NKSplitViewPopoverButtonDelegate> *controller = rightDetailController;
			if (controller && barButtonItem) {
				if ([controller respondsToSelector:@selector(invalidateMasterPopoverButtonItem:)]) {
					[controller invalidateMasterPopoverButtonItem:self.masterPopoverButtonItem];
				}
			}
		}
	}
	self.masterPopoverButtonItem = nil;
	self.popoverController = nil;
}

-(void) splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController {

}


#pragma mark <UIPopoverControllerDelegate>

-(BOOL) popoverControllerShouldDismissPopover:(UIPopoverController *)pc {
	return TRUE;
}

-(void) popoverControllerDidDismissPopover:(UIPopoverController *)pc {
}


#pragma mark -

-(void) dealloc {
	[navigators release]; navigators = nil;
	[popoverController release]; popoverController = nil;
	[masterPopoverButtonItem release]; masterPopoverButtonItem = nil;
	[masterPopoverButtonTitle release]; masterPopoverButtonTitle = nil;
	[super dealloc];
}

@end
