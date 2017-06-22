//
//  XUIButton.m
//  XUIKit
//
//  Created by Jovi on 6/19/17.
//  Copyright © 2017 Jovi. All rights reserved.
//

#import "XUIButton.h"
#import "NSControl+Private.h"
#import "XUILabel.h"
#import "XUIImageView.h"
#import "NSView+XUIAdditions.h"
#import "NSControl+XUIAdditions.h"

#define INSETS_TO_FRAME(EdgeInsets,Frame)\
NSMakeRect(EdgeInsets.left * NSWidth(Frame),EdgeInsets.bottom * NSWidth(Frame),NSWidth(Frame)*(1 - EdgeInsets.right - EdgeInsets.left) ,NSHeight(Frame)*(1 - EdgeInsets.top - EdgeInsets.bottom))

@interface XUIButtonContent : NSObject

@property (nonatomic,strong) NSString               *title;
@property (nonatomic,strong) NSAttributedString     *attributedTitle;
@property (nonatomic,strong) NSColor                *titleColor;
@property (nonatomic,strong) NSImage                *backgroundImage;
@property (nonatomic,strong) NSImage                *image;
@property (nonatomic,strong) NSFont                 *font;
@property (nonatomic,assign) BOOL                   underLined;
@property (nonatomic,strong) NSColor                *backgroundColor;

@end

@implementation XUIButtonContent{
    NSString               *_title;
    NSAttributedString     *_attributedTitle;
    NSColor                *_titleColor;
    NSImage                *_backgroundImage;
    NSImage                *_image;
    NSFont                 *_font;
    BOOL                   _underLined;
    NSColor                *_backgroundColor;
}

@end


@implementation XUIButton{
    NSMutableDictionary		*_contentLookup;
    NSEdgeInsets            _titleEdgeInsets;
    NSEdgeInsets            _imageEdgeInsets;
    
    XUIImageView            *_imageView;
    XUILabel                *_titleView;
    
    struct {
        unsigned int isNormalStringValue:1;
        unsigned int dimsInBackground:1;
        unsigned int buttonType:8;
    } _buttonFlags;
}

+ (id)button{
    return [self buttonWithType:XUIButtonTypeCustom];
}

+ (id)buttonWithType:(XUIButtonType)buttonType{
    XUIButton *button = [[self alloc] initWithFrame:NSZeroRect];
    return button;
}

- (BOOL)dimsInBackground{
    return _buttonFlags.dimsInBackground;
}

- (void)setDimsInBackground:(BOOL)bValue{
    _buttonFlags.dimsInBackground = bValue;
}

-(XUIButtonType)buttonType{
    return _buttonFlags.buttonType;
}

-(XUILabel *)titleLabel{
    if(nil == _titleView) {
        _titleView = [[XUILabel alloc] initWithFrame:NSZeroRect];
        _titleView.backgroundColor = [NSColor clearColor];
        [self addSubview:_titleView];
    }
    return _titleView;
}

-(XUIImageView *)imageView{
    if(nil == _imageView) {
        _imageView = [[XUIImageView alloc] initWithFrame:NSZeroRect];
        _imageView.backgroundColor = [NSColor clearColor];
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (NSRect)backgroundRectForBounds:(NSRect)bounds{
    return bounds;
}

- (NSRect)contentRectForBounds:(NSRect)bounds{
    return bounds;
}

- (NSRect)titleRectForContentRect:(NSRect)contentRect{
    return contentRect;
}

- (NSRect)imageRectForContentRect:(NSRect)contentRect{
    return contentRect;
}


#pragma mark - Private method

-(void)__initializeXUIButton{
    _contentLookup = [[NSMutableDictionary alloc] init];
    _buttonFlags.buttonType = XUIButtonTypeCustom;
    _buttonFlags.dimsInBackground = YES;
    _buttonFlags.isNormalStringValue = YES;
    XUIButtonContent *content = [self __contentForState:XUIControlStateNormal];
    [content setTitle:@""];
    [content setTitleColor:[NSColor blackColor]];
    [content setBackgroundImage:nil];
    [content setImage:nil];
    [content setAttributedTitle:nil];
    [content setUnderLined:NO];
    [content setFont:[NSFont fontWithName:@"Helvetica Neue Light" size:15]];
    [content setBackgroundColor:[NSColor whiteColor]];
    
    _imageEdgeInsets = NSEdgeInsetsMake(0, 0.05, 0, 0.65);
    _titleEdgeInsets = NSEdgeInsetsMake(0, 0.35, 0, 0.1);
    
    [super setTitle:@""];
    [self setBezelStyle:NSRegularSquareBezelStyle];
    [self setButtonType:NSMomentaryChangeButton];
    [self setImagePosition:NSImageOnly];
    [(NSButtonCell *)[self cell] setImageScaling:NSImageScaleProportionallyUpOrDown];
    [self setFocusRingType:NSFocusRingTypeNone];
    
    [self.imageView setUserInteractionEnabled:NO];
    [self.titleLabel setUserInteractionEnabled:NO];
    [self __updateLookup];
}

-(void)__updateLookup{
    [self.imageView setFrame:INSETS_TO_FRAME(_imageEdgeInsets,self.frame)];
    [self.titleLabel setFrame:INSETS_TO_FRAME(_titleEdgeInsets,self.frame)];
    [super setImage:[self currentBackgroundImage]];
    [_imageView setImage:[self currentImage]];
    if (_buttonFlags.isNormalStringValue) {
        [_titleView setStringValue:[self currentTitle]];
        [_titleView setFont:[self currentFont]];
        [_titleView setBackgroundColor:[self currentBackgroundColor]];
        [_titleView setTextColor:[self currentTitleColor]];
    }
}

#pragma mark - Override method

-(instancetype)init{
    self = [super init];
    if (self) {
        [self __initializeXUIButton];
    }
    return self;

}

-(instancetype)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self __initializeXUIButton];
    }
    return self;
}

- (void)__stateWillChange{
    
}

- (void)__stateDidChange{
    [self __updateLookup];
}

#pragma mark - Content Lookup

- (XUIButtonContent *)__contentForState:(XUIControlState)state{
    id key = [NSNumber numberWithInteger:state];
    XUIButtonContent *content = [_contentLookup objectForKey:key];
    if(nil == content) {
        content = [[XUIButtonContent alloc] init];
        [_contentLookup setObject:content forKey:key];
    }
    return content;
}

- (void)setTitle:(NSString *)title forState:(XUIControlState)state{
    [self __stateWillChange];
    [[self __contentForState:state] setTitle:title];
    [self setNeedsDisplay];
    [self __stateDidChange];
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle forState:(XUIControlState)state{
    [self __stateWillChange];
    [[self __contentForState:state] setAttributedTitle:attributedTitle];
    [self setNeedsDisplay];
    [self __stateDidChange];
}

- (void)setTitleColor:(NSColor *)color forState:(XUIControlState)state{
    [self __stateWillChange];
    [[self __contentForState:state] setTitleColor:color];
    [self setNeedsDisplay];
    [self __stateDidChange];
}

- (void)setBackgroundImage:(NSImage *)image forState:(XUIControlState)state{
    [self __stateWillChange];
    [[self __contentForState:state] setBackgroundImage:image];
    [self setNeedsDisplay];
    [self __stateDidChange];
}

- (void)setImage:(NSImage *)image forState:(XUIControlState)state{
    [self __stateWillChange];
    [[self __contentForState:state] setImage:image];
    [self setNeedsDisplay];
    [self __stateDidChange];
}

- (void)setFont:(NSFont *)font forState:(XUIControlState)state{
    [self __stateWillChange];
    [[self __contentForState:state] setFont:font];
    [self setNeedsDisplay];
    [self __stateDidChange];
}

- (void)setUnderLined:(BOOL)bUnderlined forState:(XUIControlState)state{
    [self __stateWillChange];
    [[self __contentForState:state] setUnderLined:bUnderlined];
    [self setNeedsDisplay];
    [self __stateDidChange];
}

- (void)setBackgroundColor:(NSColor *)color forState:(XUIControlState)state{
    [self __stateWillChange];
    [[self __contentForState:state] setBackgroundColor:color];
    [self setNeedsDisplay];
    [self __stateDidChange];
}

- (NSString *)titleForState:(XUIControlState)state{
    return [[self __contentForState:state] title];
}

- (NSAttributedString *)attributedTitleForState:(XUIControlState)state{
    return [[self __contentForState:state] attributedTitle];
}

- (NSColor *)titleColorForState:(XUIControlState)state{
    return [[self __contentForState:state] titleColor];
}

- (NSImage *)backgroundImageForState:(XUIControlState)state{
    return [[self __contentForState:state] backgroundImage];
}

- (NSImage *)imageForState:(XUIControlState)state{
    return [[self __contentForState:state] image];
}

- (NSFont *)FontForState:(XUIControlState)state{
    return [[self __contentForState:state] font];
}

- (BOOL)isUnderlinedForState:(XUIControlState)state{
    return [[self __contentForState:state] underLined];
}

- (NSColor *)backgroundColorForState:(XUIControlState)state{
    return [[self __contentForState:state] backgroundColor];
}

- (NSString *)currentTitle{
    NSString *title = [self titleForState:self.controlState];
    if(nil == title) {
        title = [self titleForState:XUIControlStateNormal];
    }
    return title;
}

-(NSAttributedString *)currentAttributedTitle{
    NSAttributedString *attributedTitle = [self attributedTitleForState:self.controlState];
    if(nil == attributedTitle) {
        attributedTitle = [self attributedTitleForState:XUIControlStateNormal];
    }
    return attributedTitle;
}

-(NSColor *)currentTitleColor{
    NSColor *titleColor = [self titleColorForState:self.controlState];
    if(nil == titleColor) {
        titleColor = [self titleColorForState:XUIControlStateNormal];
    }
    return titleColor;
}

-(NSImage *)currentBackgroundImage{
    NSImage *backgroundImage = [self backgroundImageForState:self.controlState];
    if(nil == backgroundImage) {
        backgroundImage = [self backgroundImageForState:XUIControlStateNormal];
    }
    return backgroundImage;
}

-(NSImage *)currentImage{
    NSImage *image = [self imageForState:self.controlState];
    if(nil == image) {
        image = [self imageForState:XUIControlStateNormal];
    }
    return image;
}

-(NSFont *)currentFont{
    NSColor *font = [self FontForState:self.controlState];
    if(nil == font) {
        font = [self FontForState:XUIControlStateNormal];
    }
    return font;
}

-(BOOL)currentUnderLined{
    return [self isUnderlinedForState:self.controlState];
}

-(NSColor *)currentBackgroundColor{
    NSColor *backgroundColor = [self backgroundColorForState:self.controlState];
    if(nil == backgroundColor) {
        backgroundColor = [self backgroundColorForState:XUIControlStateNormal];
    }
    return backgroundColor;
}

@end