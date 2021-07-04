#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

void hs_init(void *, void *);
void runHsMain(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        CGSize maximumLabelSize = CGSizeMake(310, CGFLOAT_MAX);
//        NSString *s = @"weqwegjhgqjq QHJ Ghjqwg ehwqg ehjqg ejqhW GJHQ GEjhqw gejqwh gjqhw fkj🎆😀❤️‍🔥🕴️🚴‍♂️🎆😀❤️‍🔥🕴️🚴‍♂️🎆😀❤️‍🔥🕴️🚴‍♂️🎆😀❤️‍🔥🕴️🚴‍♂️🎆😀❤️‍🔥🕴️🚴‍♂️🎆😀❤️‍🔥🕴️🚴‍♂️🎆😀❤️‍🔥🕴️🚴‍♂️🎆😀❤️‍🔥🕴️🚴‍♂️🎆😀❤️‍🔥🕴️🚴‍♂️🎆😀❤️‍🔥🕴️🚴‍♂️🎆😀❤️‍🔥🕴️🚴‍♂️🎆😀❤️‍🔥🕴️🚴‍♂️🎆😀❤️‍🔥🕴️🚴‍♂️🎆😀❤️‍🔥🕴️🚴‍♂️🎆😀❤️‍🔥🕴️🚴‍♂️wwew";
        NSString *s = @"🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️🎆😀🕴️Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

        CGRect textRect = [s boundingRectWithSize:maximumLabelSize
                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]}
                                                 context:nil];
//        UIKIT_EXTERN NSAttributedStringKey const NSFontAttributeName API_AVAILABLE(macos(10.0), ios(6.0));                // UIFont, default Helvetica(Neue) 12
        
//        NSLog(@"q: %e", CGFLOAT_MAX);
        NSLog(@"objc_q: %@", NSStringFromCGRect(textRect));
        
        CGPoint p = CGPointMake(123, 456);
        [[UIView new] convertPoint:p toView:[UIView new]];
        
//        ("convertPoint:toView:", p, to) %<.%@. from

        
//        NSMutableDictionary *d;
//        [d setValue:<#(nullable id)#> forKey:<#(nonnull NSString *)#>]
        
        hs_init(&argc, &argv);
        runHsMain();
//        [[NSString new]
//         boundingRectWithSize:<#(CGSize)#>
//         options:<#(NSStringDrawingOptions)#>
//         attributes:<#(nullable NSDictionary<NSAttributedStringKey,id> *)#>
//         context:<#(nullable NSStringDrawingContext *)#>
//         ]
        
    }
}
