module Ui
( createUi
) where

import Objc

--createUi root = do
 --print "1231231231"
 --pure ()
createUi root = do
 --scrollView <- ("initWithFrame:", scrollViewFrame) <.# "alloc" @| "NSScrollView"
 --("addSubview:", scrollView) <.@. root

 let subviewFrame@(_,_,_, subviewFrameHeight) = (0, 0, 200, 800)
 documentView <- ("initWithFrame:", subviewFrame) <.# "alloc" @| "NSView"
 let scrollViewFrame = (0, 0, 200, 200)
 scrollView <- ("initWithFrame:", scrollViewFrame) <.# "alloc" @| "NSScrollView"
 ("setBackgroundColor:", ("colorWithAlphaComponent:", 0.4) <.+ "redColor" @| "NSColor") <@. scrollView
 ("setDocumentView:", documentView) <.@. scrollView
 ("scrollToPoint:", (0, subviewFrameHeight)) <.% "contentView" @<. scrollView
 ("setHasVerticalScroller:", ptrBool True) <.@. scrollView
 ("addSubview:", scrollView) <.@. root
