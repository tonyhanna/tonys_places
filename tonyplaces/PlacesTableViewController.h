//
//  PlacesTableViewController.h
//  tonyplaces
//
//  Created by Dominikus Putranto on 5/30/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PlacesTableViewCell.h"

@class PlaceModel;

enum {
    mapOff,
    mapOffToOn,
    mapOn,
    mapOnToOff
};

@interface PlacesTableViewController : UITableViewController<PlacesTableViewCellDelegate> {
    NSMutableArray * dataSource;
    UIScrollView * mapView;
    int tabType;
    id delegate;
    
    int mapState;
    bool isEditingRow;
    //NSIndexPath * selectedRow;
    
    NSTimer * cellEndEditingDelayTimer;
}

@property (nonatomic,retain) UIView * mapView;
@property (nonatomic,retain) id delegate;
@property (nonatomic,assign) int tabType;
//@property (nonatomic,retain) NSIndexPath * selectedRow;

- (NSArray*)dataSource;
- (void)setDataSource:(NSMutableArray*)data tabType:(int)_tabType;
- (int)getPlaceIndex:(PlaceModel*)place;
- (void)resortRows;
- (void)reloadVisibleCells;

@end

@protocol PlacesTableViewControllerDelegate <NSObject>

@optional
- (void)placesTableAddButtonTouch:(PlaceModel*)place;
@optional
- (void)placesTableRowSelected:(NSIndexPath*)indexPath;
@optional
- (void)placesTableRowDeselected:(NSIndexPath*)indexPath;
@optional
- (void)placesTableDeleteRow:(NSIndexPath*)indexPath;

@end