//
//  PlacesTableViewController.m
//  tonyplaces
//
//  Created by Dominikus Putranto on 5/30/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import "PlacesTableViewController.h"
#import "PlaceModel.h"
#import "LocationHelper.h"
#import "AppModel.h"
#import <QuartzCore/QuartzCore.h>

@implementation PlacesTableViewController

@synthesize delegate, mapView, tabType;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //self.tableView.alwaysBounceVertical = false;
        mapState = mapOff;
        self.tableView.scrollsToTop = YES;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -1, 0);
    }
    return self;
}

- (void)dealloc
{
    [dataSource release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSArray*)dataSource
{
    return dataSource;
}

- (void)setDataSource:(NSMutableArray*)data tabType:(int)_tabType
{
    //[selectedRow release];
    //selectedRow = nil;
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    
    if (dataSource != nil){
        [dataSource release];
        dataSource = nil;
    }
    tabType = _tabType;
    dataSource = [data retain];
    [self.tableView reloadData];
    isEditingRow = false;
}

- (int)getPlaceIndex:(PlaceModel*)place
{
    return [dataSource indexOfObject:place];
}

- (void)resortRows
{
    if (isEditingRow)
        return;
    //NSLog(@"resort");
    if (dataSource != nil){
        PlaceModel * selectedPlace = nil;
        if ([self.tableView indexPathForSelectedRow] != nil){
            selectedPlace = [dataSource objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        }
        [dataSource sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]]];
        [self.tableView reloadData];
        if (selectedPlace != nil){
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[dataSource indexOfObject:selectedPlace] inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void)reloadVisibleCells
{
    if (tabType == tabNavigate){
        NSArray * rows = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath * indexPath in rows){
            PlacesTableViewCell * cell = (PlacesTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            PlaceModel * place = cell.place;
            CLLocation * location = [[CLLocation alloc] initWithLatitude:place.latitude longitude:place.longitude];
            place.distance = [[AppModel instance].ownLocation distanceFromLocation:location];    
            place.bearing = [LocationHelper calculateBearingFrom:[AppModel instance].ownLocation.coordinate to:location.coordinate];
            [location release];
            [cell refresh];
        }
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:42.f/256 alpha:1];
    self.tableView.rowHeight = 83;
    self.tableView.separatorColor = [UIColor colorWithWhite:69.f/256 alpha:1];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.allowsSelection = NO;
    //dataSource = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - PlacesTableViewCellDelegate

- (void)placesCellButtonAddTouch:(id)sender
{
    PlacesTableViewCell *cell = (PlacesTableViewCell*)sender;
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    PlaceModel * place = (PlaceModel*)[dataSource objectAtIndex:indexPath.row];
    place.addedNavigate = true;
    cell.buttonAdd.hidden = cell.textDistance.hidden = YES;
    if ([delegate respondsToSelector:@selector(placesTableAddButtonTouch:)]){
        [delegate performSelector:@selector(placesTableAddButtonTouch:) withObject:place];
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView){
        if (mapState == mapOffToOn){
            self.tableView.contentOffset = CGPointMake(0, 0);
            //mapView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y);
        } else if (mapState == mapOn){
            if (self.tableView.contentOffset.y <= 0){
                mapView.frame = CGRectMake(0, -self.tableView.contentOffset.y, mapView.frame.size.width, mapView.frame.size.height);
            }
        }
    } else if (scrollView == mapView){
        if (mapState == mapOn){
            float mapHeight = mapView.frame.size.height - mapView.contentOffset.y;
            self.tableView.frame = CGRectMake(0, mapHeight, self.tableView.frame.size.width, self.tableView.superview.frame.size.height - mapHeight);
        } else if (mapState == mapOnToOff){
            //float mapHeight = mapView.layer.position.y + mapView.frame.size.height - mapView.contentOffset.y;
            mapView.contentOffset = CGPointMake(0, 0);
            //self.tableView.layer.position = CGPointMake(self.tableView.frame.size.width/2, self.tableView.frame.size.height/2 + mapHeight);
            //[[self.tableView.layer presentationLayer] setFrame:CGRectMake(0, mapHeight, self.tableView.frame.size.width, self.tableView.superview.frame.size.height - mapHeight)];
            //self.tableView.layer.frame = CGRectMake(0, mapHeight, self.tableView.frame.size.width, self.tableView.superview.frame.size.height - mapHeight);
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    //prevent deceleration when pulling map down
    if (scrollView == self.tableView){
        if (mapState == mapOffToOn){
            [scrollView setContentOffset:scrollView.contentOffset animated:YES];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{    
    if (scrollView == self.tableView){
        if (mapState == mapOff){
            if (self.tableView.contentOffset.y < -50){
                //[scrollView setContentOffset:scrollView.contentOffset animated:YES];
                float offsetY = self.tableView.contentOffset.y;
                [mapView removeFromSuperview];
                [self.tableView.superview addSubview:mapView];
                self.tableView.frame = CGRectMake(0, -offsetY, self.tableView.frame.size.width, self.tableView.superview.frame.size.height);
                mapView.frame = CGRectMake(0, -mapView.frame.size.height-offsetY, mapView.frame.size.width, mapView.frame.size.height);
                self.tableView.contentOffset = CGPointMake(0, 0);
                
                mapView.scrollEnabled = self.tableView.scrollEnabled = false;
                mapState = mapOffToOn;
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.25];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(mapOffToOnFinish:finished:context:)];
                
                self.tableView.frame = CGRectMake(0, mapView.frame.size.height, self.tableView.frame.size.width, self.tableView.superview.frame.size.height);
                mapView.frame = CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height);
                [UIView commitAnimations];
            }
        } 
    } else if (scrollView == mapView){
        if (mapState == mapOn){ 
            if (mapView.contentOffset.y > 50){
                        //[scrollView setContentOffset:scrollView.contentOffset animated:YES];
                float offsetY = mapView.contentOffset.y;
                mapView.frame = CGRectMake(0, -offsetY, mapView.frame.size.width, mapView.frame.size.height);
                mapView.contentOffset = CGPointMake(0, 0);
                self.tableView.frame = CGRectMake(0, mapView.frame.size.height-offsetY, self.tableView.frame.size.width, self.tableView.superview.frame.size.height);
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -1, 0);
                
                mapView.scrollEnabled = self.tableView.scrollEnabled = false;
                mapState = mapOnToOff;
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                [UIView setAnimationDuration:0.25];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(mapOnToOffFinish:finished:context:)];
                self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.superview.frame.size.height);
                mapView.frame = CGRectMake(0, -mapView.frame.size.height, mapView.frame.size.width, mapView.frame.size.height);
                [UIView commitAnimations];
            } 
            //else {
            //    [mapView setContentOffset:CGPointMake(0, 0) animated:YES];
            //}
        }

    }
}

- (void)mapOffToOnFinish:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    NSLog(@"offtoonfinish");
    mapView.scrollEnabled = self.tableView.scrollEnabled = true;
    self.tableView.frame = CGRectMake(0, mapView.frame.size.height, self.tableView.frame.size.width, self.tableView.superview.frame.size.height - mapView.frame.size.height);
    //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tableView.rowHeight, 0);
    
    self.tableView.allowsSelection = YES;
    
    mapState = mapOn;
}

- (void)mapOnToOffFinish:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    mapView.scrollEnabled = self.tableView.scrollEnabled = true;
    [mapView removeFromSuperview];
    mapView.frame = CGRectMake(0, -mapView.frame.size.height, mapView.frame.size.width, mapView.frame.size.height);
    [self.tableView addSubview:mapView];
    
    self.tableView.allowsSelection = NO;
    NSIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self tableView:self.tableView didDeselectRowAtIndexPath:indexPath];
    
    mapState = mapOff;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [PlacesTableViewCell reuseIdentifierType:tabType];
    
    PlacesTableViewCell * cell = (PlacesTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        NSArray * topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PlacesTableViewCell" owner:nil options:nil];
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[PlacesTableViewCell class]]){
                cell = currentObject;
                [cell initOnce];
                break;
            }
        }
    } 
    [cell initView:tabType withDelegate:self]; 
    PlaceModel * place = [dataSource objectAtIndex:indexPath.row];
    cell.place = place;
    cell.textCaption.text = place.name;
    cell.textSubcaption.text = place.address;
    if (tabType == tabNavigate){
        CLLocation * location = [[CLLocation alloc] initWithLatitude:place.latitude longitude:place.longitude];
        //cell.textSubcaption.text = [place categoriesAsString];
        place.distance = [[AppModel instance].ownLocation distanceFromLocation:location];    
        place.bearing = [LocationHelper calculateBearingFrom:[AppModel instance].ownLocation.coordinate to:location.coordinate];
        [location release];
        [cell refresh];
    } else if (tabType == tabAddVenue){
        cell.buttonAdd.hidden = cell.textDistance.hidden = place.addedNavigate;
    }
    NSIndexPath * selectedRow = [self.tableView indexPathForSelectedRow];
    if (selectedRow == nil || indexPath.row != selectedRow.row) {
        [cell setSelected:NO animated:NO];
    } else {
         [cell setSelected:YES animated:NO];
    }
    // Configure the cell...
    
    return cell;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([AppModel instance].role == ROLE_ADMIN){
        if (tabType == tabNavigate){
            return UITableViewCellEditingStyleDelete;
        } else if (tabType == tabAddVenue){
            return UITableViewCellEditingStyleNone;
        } else {
            return UITableViewCellEditingStyleNone;
        }
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cellEndEditingDelayTimer != nil){
        [cellEndEditingDelayTimer invalidate];
    }
    isEditingRow = true;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    cellEndEditingDelayTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(tableViewCellEndEditing:) userInfo:nil repeats:NO];
}

- (void)tableViewCellEndEditing:(NSTimer*)timer
{
    [timer invalidate];
    cellEndEditingDelayTimer = nil;
    isEditingRow = false;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if ([delegate respondsToSelector:@selector(placesTableDeleteRow:)]){
            [delegate performSelector:@selector(placesTableDeleteRow:) withObject:indexPath];
        }
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return mapViewVisible?mapView:nil;
    } else {
        return nil;
    }
}  

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return mapViewVisible?mapView.frame.size.height:0;
    } else {
        return 0;
    }
}*/

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (mapState == mapOn){
        return indexPath;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if method called directly, don't delegate
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    if (tableView != nil){
        if ([delegate respondsToSelector:@selector(placesTableRowSelected:)]){
            [delegate performSelector:@selector(placesTableRowSelected:) withObject:indexPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != nil){
        if ([delegate respondsToSelector:@selector(placesTableRowDeselected:)]){
            [delegate performSelector:@selector(placesTableRowDeselected:) withObject:indexPath];
        }
    }
}

@end
