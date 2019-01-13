module Window
( setupWindow
) where

import Objc
import Data.Bits

c_NSWindowStyleMaskTitled = bitN 0
c_NSWindowStyleMaskClosable = bitN 1
c_NSWindowStyleMaskMiniaturizable = bitN 2
c_NSWindowStyleMaskResizable = bitN 3

c_NSBackingStoreBuffered = 2

setupWindow = do
 let frame@(_, _, width, height) = (800, 200, 500, 500)
 w <- "new" @| "NSWindow"
 ("setFrame:display:", frame) <.#. w -- hack, pass 1 arg instead of 2
 let mask = c_NSWindowStyleMaskTitled .|. c_NSWindowStyleMaskClosable .|. c_NSWindowStyleMaskMiniaturizable .|. c_NSWindowStyleMaskResizable
 ("setStyleMask:", ptrWord mask) <.@. w
 ("setBackingType:", ptrInt c_NSBackingStoreBuffered) <.@. w
 ("setBackgroundColor:", "lightGrayColor" @| "NSColor") <@. w
 ("makeKeyAndOrderFront:", "sharedApplication" @| "NSApplication") <@. w

 v <- "new" @| "NSView"
 ("setContentView:", v) <.@. w

 pure v


    --NSView *v = [[NSView alloc] initWithFrame:(NSRect){0, 0, frame.size}];
    --window.contentView = v;

    --CGRect subviewFrame = {0, 0, 200, 800};
    --NSView *documentView = [[NSView alloc] initWithFrame:subviewFrame];
    --CGRect scrollViewFrame = {0, 0, 200, 200};
    --NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:scrollViewFrame];
    --scrollView.backgroundColor = [NSColor.greenColor colorWithAlphaComponent:0.4];
    --scrollView.documentView = documentView;
    --[scrollView.contentView scrollToPoint:(NSPoint){0, subviewFrame.size.height}];
    --scrollView.hasVerticalScroller = YES;

    --[v addSubview:scrollView];
