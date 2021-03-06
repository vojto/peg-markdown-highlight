/* PEG Markdown Highlight
 * Copyright 2011 Ali Rantakari -- http://hasseg.org
 * Licensed under the GPL2+ and MIT licenses (see LICENSE for more info).
 * 
 * HGMarkdownHighlightingStyle.m
 */

#import "HGMarkdownHighlightingStyle.h"

#define kMinFontSize 4

@implementation HGMarkdownHighlightingStyle

+ (NSColor *) colorFromARGBColor:(pmh_attr_argb_color *)argb_color
{
	return [NSColor colorWithDeviceRed:(argb_color->red / 255.0)
								 green:(argb_color->green / 255.0)
								  blue:(argb_color->blue / 255.0)
								 alpha:(argb_color->alpha / 255.0)];
}

- (id) initWithType:(pmh_element_type)elemType
	attributesToAdd:(NSDictionary *)toAdd
		   toRemove:(NSArray *)toRemove
	fontTraitsToAdd:(NSFontTraitMask)traits
{
	if (!(self = [super init]))
		return nil;
	
	self.elementType = elemType;
	self.attributesToAdd = toAdd;
	self.attributesToRemove = toRemove;
	self.fontTraitsToAdd = traits;
	
	return self;
}

- (id) initWithStyleAttributes:(pmh_style_attribute *)attributes
					  baseFont:(NSFont *)baseFont
{
	if (!(self = [super init]))
		return nil;
	
	pmh_style_attribute *cur = attributes;
	self.elementType = cur->lang_element_type;
	self.fontTraitsToAdd = 0;
	
	NSMutableDictionary *toAdd = [NSMutableDictionary dictionary];
	NSString *fontName = nil;
	CGFloat fontSize = 0;
	BOOL fontSizeIsRelative = NO;
	
	while (cur != NULL)
	{
		if (cur->type == pmh_attr_type_foreground_color)
			[toAdd setObject:[HGMarkdownHighlightingStyle colorFromARGBColor:cur->value->argb_color]
					  forKey:NSForegroundColorAttributeName];
		
		else if (cur->type == pmh_attr_type_background_color)
			[toAdd setObject:[HGMarkdownHighlightingStyle colorFromARGBColor:cur->value->argb_color]
					  forKey:NSBackgroundColorAttributeName];
		
		else if (cur->type == pmh_attr_type_font_style)
		{
			if (cur->value->font_styles->italic)
				self.fontTraitsToAdd |= NSItalicFontMask;
			if (cur->value->font_styles->bold)
				self.fontTraitsToAdd |= NSBoldFontMask;
			if (cur->value->font_styles->underlined)
				[toAdd setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle]
						  forKey:NSUnderlineStyleAttributeName];
		}
		
		else if (cur->type == pmh_attr_type_font_size_pt)
		{
			fontSize = (CGFloat)cur->value->font_size->size_pt;
			fontSizeIsRelative = (cur->value->font_size->is_relative == true);
		}
		
		else if (cur->type == pmh_attr_type_font_family)
			fontName = [NSString stringWithUTF8String:cur->value->font_family];
		
		cur = cur->next;
	}
	
	if (fontName != nil || fontSize != 0)
	{
		if (fontName == nil)
			fontName = [baseFont familyName];
		
		CGFloat actualFontSize;
		if (fontSize != 0)
		{
			actualFontSize = fontSizeIsRelative ? ([baseFont pointSize] + fontSize) : fontSize;
			if (actualFontSize < kMinFontSize)
				actualFontSize = kMinFontSize;
		}
		else
			actualFontSize = [baseFont pointSize];
		
		[toAdd setObject:[NSFont fontWithName:fontName size:actualFontSize]
				  forKey:NSFontAttributeName];
	}
	
	self.attributesToAdd = toAdd;
	self.attributesToRemove = nil;
	
	return self;
}

- (void) dealloc
{
	self.attributesToAdd = nil;
	self.attributesToRemove = nil;
	[super dealloc];
}

@synthesize elementType;
@synthesize attributesToAdd;
@synthesize attributesToRemove;
@synthesize fontTraitsToAdd;

@end
