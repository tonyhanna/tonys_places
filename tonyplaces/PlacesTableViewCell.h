//
//  PlacesCellViewController.h
//  tonyplaces
//
//  Created by Dominikus Putranto on 5/30/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    editingOff, editingOffToOn, editingOn, editingOnToOff
};

@class PlaceModel;

@interface PlacesTableViewCell : UITableViewCell {
    UITextField * textCaption;
    UITextField * textSubcaption;
    UITextField * textDistance;
    UIImageView * arrow;
    UIView * containerAccessory;
    UIButton * buttonAdd;
    UIButton * buttonRemove;
    
    id delegate;
    int tabType;
    
    PlaceModel * place;
    int stateEditing;
}

@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) IBOutlet UITextField * textCaption;
@property (nonatomic,retain) IBOutlet UITextField * textSubcaption;
@property (nonatomic,retain) IBOutlet UITextField * textDistance;
@property (nonatomic,retain) IBOutlet UIView * containerAccessory;
@property (nonatomic,retain) IBOutlet UIImageView * arrow;
@property (nonatomic,retain) IBOutlet UIButton * buttonAdd;
@property (nonatomic,retain) IBOutlet UIButton * buttonRemove;

@property (nonatomic,retain) PlaceModel * place;

- (void)initOnce;
- (void)initView:(int)_tabType withDelegate:(id)delegate;
- (void)rotateArrow:(double)degree;
- (void)refresh;

+ (NSString *)reuseIdentifierType:(int)_tabType;

@end

@protocol PlacesTableViewCellDelegate <NSObject>

@optional
- (void)placesCellButtonAddTouch:(PlacesTableViewCell*)cell;

@end