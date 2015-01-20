//
//  SimPickerView.m
//  SimPickerView
//
//  Created by CHING PING on 2014/12/31.
//  Copyright (c) 2014年 CHING PING. All rights reserved.
//

#import "SimPickerView.h"
#import "CenterLayout.h"
#import "SimPickerViewCell.h"

#define CellID @"cell"

@implementation SimPickerView


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        CGRect effectFrame = self.frame;
        effectFrame.size.width = [[UIScreen mainScreen] bounds].size.width;
        [self commonInit: effectFrame];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        [self commonInit: frame];
     }
    return self;
}

- (void)commonInit:(CGRect)frame
{
    _DisplayedItems = 5;
    _MinLineSpacing = 1;
    _CellHeight = (frame.size.height - (_MinLineSpacing * (_DisplayedItems -1))) / _DisplayedItems;

    _collectionView = [[UICollectionView alloc]
                       initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)
                       collectionViewLayout: [[CenterLayout alloc] initWithCellHeight: _CellHeight  displayedItems: _DisplayedItems minimumLineSpacing: _MinLineSpacing]];


    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    [self addSubview: _collectionView];

    UINib *nib = [UINib nibWithNibName: @"SimPickerViewCell" bundle: nil];
    [_collectionView registerNib: nib forCellWithReuseIdentifier: CellID];

    [self addSubview: [self makeFocusGlass]];
    self.buttonDisclosure = [self makeButtonDisclosure];
    self.swipeGesture = [self makeSwipeGestureRecognizer];
}

// mark disclosure take effect only when
// view did appear, must be called
// from the view controller's viewDidAppear

- (void)markFirstDisclosure
{
    static dispatch_once_t once;
    dispatch_once(&once, ^ {

        [self collectionView: self.collectionView didSelectItemAtIndexPath: [NSIndexPath indexPathForItem: 0 inSection: 0]];
    });
}

- (UISwipeGestureRecognizer *)makeSwipeGestureRecognizer
{
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector(swipeGestureRecognized:)];
    return gesture;
}

- (UIImageView *)makeFocusGlass
{
    NSInteger emptyItemSpaces = self.DisplayedItems / 2;
    CGRect focusPlaceholder = CGRectInset(self.collectionView.frame, 0, (self.CellHeight + self.MinLineSpacing) * emptyItemSpaces);

    UIImageView *imageView = [[UIImageView alloc] initWithFrame: focusPlaceholder];
    imageView.image = [UIImage imageNamed: @"glass"];
    [self addSubview: imageView];
    return imageView;
}

- (UIButton *)makeButtonDisclosure
{
    UIButton *button = [[UIButton alloc] init];
    // buttom frame will be setup in [SimPickerViewCell addButton:]
    [button addTarget: self action: @selector(buttonDisclosurePressed:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *image = [UIImage imageNamed: @"arrow-disclosure"];
    [button setImage: image forState: UIControlStateNormal];
    return button;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(numberOfRowsInPickerView:)]) {
        return [self.delegate numberOfRowsInPickerView: self];
    }
    else {
        DMLog(@"no available delegate object");
        return 0;
    }

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimPickerViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier: CellID forIndexPath:indexPath];

    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(pickerView:titleForRow:)]) {
        cell.name.text = [self.delegate pickerView: self titleForRow: indexPath.row];
    }
    else {
        cell.name.text = @"";
        DMLog(@"no available title");
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

    CGSize itemSize = CGSizeMake(self.collectionView.bounds.size.width, self.CellHeight);
    //DMLog(@"itemSize = %.2f, %.2f", itemSize.width, itemSize.height);
    return itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //DMLog(@"select item %ld", (long)indexPath.item);
    [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SimPickerViewCell *cell = (SimPickerViewCell *)obj;
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    }];

    [self.collectionView selectItemAtIndexPath: indexPath animated: YES scrollPosition: UICollectionViewScrollPositionCenteredVertically];

    SimPickerViewCell *cell = (SimPickerViewCell *)[self.collectionView cellForItemAtIndexPath: indexPath];
    [cell addButton: self.buttonDisclosure];
    [cell addGestureRecognizer: self.swipeGesture];

    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(pickerView:didSelectRow:)]) {
        [self.delegate pickerView: self didSelectRow: indexPath.item];
    }
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.buttonDisclosure removeFromSuperview];

}

- (NSIndexPath *)getLastIndexPath
{
    NSInteger lastItem = [self.collectionView numberOfItemsInSection: 0] - 1;
    return [NSIndexPath indexPathForItem: lastItem inSection:0];
}


- (void)reloadData
{
    [self.collectionView reloadData];
    NSIndexPath *focusedIndexPath = [self getFocusIndexPath];
    DMLog(@"%@", focusedIndexPath);
    SimPickerViewCell *cell = (SimPickerViewCell *)[self.collectionView cellForItemAtIndexPath: focusedIndexPath];
    [cell addButton: self.buttonDisclosure];
}

// remove comment if we want have a chance
// to animate add/delete operations ourself.

- (void)deleteRow:(NSInteger)row
{
    NSIndexPath *last = [self getLastIndexPath];

    // check range
    if (row > last.item ||
        row < 0) {
        DMLog(@"delete indexPath error : %ld", row);
        return;
    }

    if ([self.collectionView numberOfItemsInSection: 0] == 1) {
        return;
    }

    // Delete the item from the data source.
    [self.delegate callbackDeleteRow: row];
    // Now delete the items from the collection view.
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem: row inSection: 0];
    [self.collectionView deleteItemsAtIndexPaths: [NSArray arrayWithObjects: indexPath, nil]];

    if ([indexPath isEqual: last]) {
        // the indexPath has just been deleted, refetch lastIndexPath
        [self collectionView:self.collectionView didSelectItemAtIndexPath: [self getLastIndexPath]];
    }
    else {
        [self collectionView:self.collectionView didSelectItemAtIndexPath: indexPath];
    }

}


- (void)insertItem:(id)newItem atRow:(NSInteger)row
{
    // insert item to data source
    [self.delegate callbackInsertItem: newItem atRow: row];
    // Now add the items to the collection view.
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem: row inSection: 0];
    [self.collectionView insertItemsAtIndexPaths: [NSArray arrayWithObjects: indexPath, nil]];

    [self collectionView:self.collectionView didSelectItemAtIndexPath: indexPath];
}

- (void)insertItem:(id)newItem afterRow:(NSInteger)row
{
    [self insertItem: newItem atRow: row + 1];
}

#pragma mark - scrolling detection
- (NSIndexPath *)getFocusIndexPath
{
    CGPoint centerPoint = CGPointMake(self.collectionView.frame.size.width / 2 + self.collectionView.contentOffset.x, self.collectionView.frame.size.height /2 + self.collectionView.contentOffset.y);
    NSIndexPath *indexPathOfCentralCell = [self.collectionView indexPathForItemAtPoint:centerPoint];
    return  indexPathOfCentralCell;
}

- (NSIndexPath *)predictedFocusIndexPath
{
    return ((CenterLayout *)self.collectionView.collectionViewLayout).focusedIndex;
}

#pragma mark - scrolling handlers
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSIndexPath *indexPath = [self getFocusIndexPath];
    SimPickerViewCell *cell = (SimPickerViewCell *) [self.collectionView cellForItemAtIndexPath: indexPath];
    DMLog(@"begin scrolling from %ld", indexPath.item);
    [self.buttonDisclosure removeFromSuperview];
    [cell removeGestureRecognizer: self.swipeGesture];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self collectionView: self.collectionView didSelectItemAtIndexPath: [self predictedFocusIndexPath]];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self collectionView: self.collectionView didSelectItemAtIndexPath: [self predictedFocusIndexPath]];
}

#pragma mark - Target Action

- (IBAction)buttonDisclosurePressed:(id)sender
{
    DMLog(@"disclosure button pressed");
}

- (IBAction)buttonDeletePressed:(id)sender
{
    DMLog(@"delete button pressed");
}

- (IBAction)swipeGestureRecognized:(id)sender
{
    DMLog(@"swipe gesture catched");
}
@end
