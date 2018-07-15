//
//  TabBarViewController.m
//  TabBarDemo
//

//
#define CUAL CEFlipAnimationController
#define IMPORT
#import "TabBarViewController.h"

@interface TabBarViewController () <UITabBarControllerDelegate>

@end

@implementation TabBarViewController {

}


- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.delegate = self;
    }
    return self;
}


@end
