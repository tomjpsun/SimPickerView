//
//  SimPickerView.h
//  SimPickerView
//
//  Created by CHING PING on 2014/12/31.
//  Copyright (c) 2014年 CHING PING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimPickerSupplementary.h"


@class SimPickerView;


@protocol SimPickerDelegateProtocol <NSObject>
- (NSInteger)numberOfRowsInPickerView:(SimPickerView *)pickerView;
- (NSString *)pickerView:(SimPickerView *)pickerView titleForRow:(NSInteger)row;
- (void)pickerView:(SimPickerView *)pickerView didSelectRow:(NSInteger)row;
// if callback failed, stop the insertion on SimPickerView
- (BOOL)callbackInsertItem:(id)item atRow:(NSInteger)row;
// if callback failed, stop the deletion on SimPickerView
- (BOOL)callbackDeleteRow:(NSInteger)deleteRow;
- (void)buttonDisclosurePressed:(UIButton *)btn onIndex:(NSInteger)index;
- (void)buttonDeletePressed:(UIButton *)btn onIndex:(NSInteger)index;
- (BOOL)shouldShowDeleteButtonOnIndex:(NSInteger)index;
@optional
- (void)longTouchPressedOnIndex:(NSInteger)index;
@end


@interface SimPickerView : UIView<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PickerSupplementaryTouch>
//typedef int (^completeion)(void);
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *focusImageView;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeGestureDirectionRight;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeGestureDirectionLeft;
@property (strong, nonatomic) UILongPressGestureRecognizer *longGesture;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
// properties to define the look of pickerview
@property CGFloat CellHeight;
@property NSInteger DisplayedItems;
@property (strong, nonatomic) id<SimPickerDelegateProtocol> delegate;
@property CGFloat MinLineSpacing;
@property (strong, nonatomic) UIButton *buttonDisclosure;
@property (strong, nonatomic) UIButton *buttonDelete;

// wrapper interface
- (void)didSelectItemAtRow:(NSInteger)row;
- (void)markFirstDisclosure;
- (NSIndexPath *)getFocusIndexPath;
// insert / add / delete
- (void)deleteRow:(NSInteger)deleteRow;
- (void)insertItem:(id)newItem atRow:(NSInteger)row;
- (void)insertItem:(id)newItem afterRow:(NSInteger)row;
//- (void)reloadData;
- (void)reloadDataWithCompleteion:(void (^)(void))completeion;
@end

