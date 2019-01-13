module Menu
( setupMenu
) where

import Objc
import Foreign.Ptr

setupMenu = do
 app <- "sharedApplication" @| "NSApplication"
 menu <- ("initWithTitle:", getNsString "") <@ "alloc" @| "NSMenu"

 args1 <- sequence [getNsString "", pure nullPtr, getNsString ""]

 item <- ("initWithTitle:action:keyEquivalent:", args1) <.@@ "alloc" @| "NSMenuItem"
 menu1 <- "new" @| "NSMenu"

 args2 <- sequence [getNsString "Quit", getSelByName "terminate:", getNsString "q"]

 ("addItem:", ("initWithTitle:action:keyEquivalent:", args2) <.@@ "alloc" @| "NSMenuItem") <@. menu1
 ("setSubmenu:", menu1) <.@. item
 ("addItem:", item) <.@. menu
 ("setAppleMenu:", menu) <.@. app
 ("setMainMenu:", menu) <.@. app

 pure ()


    --NSApplication *app = NSApplication.sharedApplication;
    --NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    --NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    --NSMenu *menu1 = NSMenu.new;
    --[menu1 addItem:[[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"]];
    --[item setSubmenu:menu1];
    --[menu addItem:item];
    --[app setAppleMenu:menu];
    --[app setMainMenu:menu];