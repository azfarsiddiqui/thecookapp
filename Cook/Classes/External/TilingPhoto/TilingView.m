/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * This file is part of PhotoScrollerNetwork -- An iOS project that smoothly and efficiently
 * renders large images in progressively smaller ones for display in a CATiledLayer backed view.
 * Images can either be local, or more interestingly, downloaded from the internet.
 * Images can be rendered by an iOS CGImageSource, libjpeg-turbo, or incrmentally by
 * libjpeg (the turbo version) - the latter gives the best speed.
 *
 * Parts taken with minor changes from Apple's PhotoScroller sample code, the
 * ConcurrentOp from my ConcurrentOperations github sample code, and TiledImageBuilder
 * was completely original source code developed by me.
 *
 * Copyright 2012 David Hoerl All Rights Reserved.
 *
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *    1. Redistributions of source code must retain the above copyright notice, this list of
 *       conditions and the following disclaimer.
 *
 *    2. Redistributions in binary form must reproduce the above copyright notice, this list
 *       of conditions and the following disclaimer in the documentation and/or other materials
 *       provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY David Hoerl ''AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL David Hoerl OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
 
#import <QuartzCore/CATiledLayer.h>

#import "TilingView.h"
#import "TiledImageBuilder.h"

#define LOG DLog

#if !__has_feature(objc_arc)
#error THIS CODE MUST BE COMPILED WITH ARC ENABLED!
#endif


@interface FastCATiledLayer : CATiledLayer

@end

@implementation FastCATiledLayer

+ (CFTimeInterval)fadeDuration
{
  return 0;
}

@end

@implementation TilingView
{
	TiledImageBuilder *tb;
    NSInteger tileCount;
}
@synthesize annotates;

+ (Class)layerClass
{
	return [FastCATiledLayer class];
}

- (void)dealloc {
    self.layer.contents = nil;
    self.layer.delegate = nil;
    [self.layer removeFromSuperlayer];
}

- (id)initWithImageBuilder:(TiledImageBuilder *)imageBuilder
{
	CGRect rect = { CGPointMake(0, 0), [imageBuilder imageSize] };
	
    if ((self = [super initWithFrame:rect])) {
        tb = imageBuilder;

        CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
        tiledLayer.levelsOfDetail = imageBuilder.zoomLevels;
		
		self.opaque = YES;
		self.clearsContextBeforeDrawing = NO;
        tileCount = 0;
    }
    return self;
}

//static inline long offsetFromScale(CGFloat scale) { long s = lrintf(1/scale); long idx = 0; while(s > 1) s /= 2.0f, ++idx; return idx; }

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context
{
	if(tb.failed) return;

    CGFloat scale = CGContextGetCTM(context).a;

	// Fetch clip box in *view* space; context's CTM is preconfigured for view space->tile space transform
	CGRect box = CGContextGetClipBoundingBox(context);

	// Calculate tile index
	CGSize tileSize = [(CATiledLayer*)layer tileSize];
	CGFloat col = rintf(box.origin.x * scale / tileSize.width);
	CGFloat row = rintf(box.origin.y * scale / tileSize.height);
    
    CGFloat totalCols = ceilf((self.layer.bounds.size.width * scale) / tileSize.width);
    CGFloat totalRows = ceilf((self.layer.bounds.size.height * scale) / tileSize.height);
    CGFloat totalTiles = totalCols * totalRows;

	//LOG(@"scale=%f 1/scale=%f levelsOfDetail=%ld levelsOfDetailBias=%ld row=%f col=%f offsetFromScale=%ld", scale, 1/scale, ((CATiledLayer *)layer).levelsOfDetail, ((CATiledLayer *)layer).levelsOfDetailBias, row, col, offsetFromScale(scale));


	CGImageRef image = [tb newImageForScale:scale location:CGPointMake(col, row) box:box];

	assert(image);

	CGContextTranslateCTM(context, box.origin.x, box.origin.y + box.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	box.origin.x = 0;
	box.origin.y = 0;
//	LOG(@"Draw: scale=%f row=%d col=%d", scale, (int)row, (int)col);

	CGAffineTransform transform = [tb transformForRect:box /* scale:scale */];
	CGContextConcatCTM(context, transform);

	// Detect Rotation
	if(isnormal(transform.b) && isnormal(transform.c)) {
		CGSize s = box.size;
		box.size = CGSizeMake(s.height, s.width);
	}

	// LOG(@"BOX: %@", NSStringFromCGRect(box));

	CGContextSetBlendMode(context, kCGBlendModeCopy);	// no blending! from QA 1708
//if(row==0 && col==0)	
	CGContextDrawImage(context, box, image);
	CFRelease(image);
    tileCount++;
    if (tileCount >= totalTiles) {
        if (self.tileDelegate) {
            [self.tileDelegate finishedRenderingTiles];
        }
        tileCount = 0;
    }
}

- (CGSize)imageSize
{
	return [tb imageSize];
}

@end
