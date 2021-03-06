//
//  ChoosePersonView.h
//  Tinder
//
//  Created by 张德荣 on 16/5/17.
//  Copyright © 2016年 JsonZhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
@class Person;
@interface ChoosePersonView : MDCSwipeToChooseView

@property (nonatomic, strong, readonly) Person *person;

- (instancetype)initWithFrame:(CGRect)frame
                       person:(Person *)person
                      options:(MDCSwipeToChooseViewOptions *)options;
@end







