//
//  TabsView.swift
//  catowser
//
//  Created by admin on 12/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit

// https://stackoverflow.com/a/24104371/483101
// My understanding is that using class, you guarantee that this protocol
// will be used only on classes and no other stuff like enums or structs.

protocol TabsDelegate: class {
    func tabsView(tabsView: TabsView, didAppendTab: TabView)  -> Void
    func tabsView(tabsView: TabsView, didCloseTab: TabView) -> Void
    func tabsView(tabsView: TabsView, willTab: TabView, moveFromPosition: UInt, toPosition: UInt) -> Void
    func tabsView(tabsView: TabsView, willPinTab: TabView) -> Void
}

// https://stackoverflow.com/a/15978951/483101
// Apple defined pretty clearly how to subclass UIView in the doc.
//
// Check out the list below, especially take a look at initWithFrame: and layoutSubviews. The former is intended to setup the frame of your UIView whereas the latter is intended to setup the frame and the layout of its subviews.
//
// Also remember that initWithFrame: is called only if you are instantiating your UIView programmatically. If you are loading it from a nib file (or a storyboard), initWithCoder: will be used. And in initWithCoder: the frame hasn't been calculated yet, so you cannot modify the frame you set up in Interface Builder. As suggested in this answer you may think of calling initWithFrame: from initWithCoder: in order to setup the frame.
//
// Finally, if you load your UIView from a nib (or a storyboard), you also have the awakeFromNib opportunity to perform custom frame and layout initializations, since when awakeFromNib is called it's guaranteed that every view in the hierarchy has been unarchived and initialized.
//
// From the doc of NSNibAwaking
//
// Messages to other objects can be sent safely from within awakeFromNib—by which time it’s assured that all the objects are unarchived and initialized (though not necessarily awakened, of course)
// It's also worth noting that with autolayout you shouldn't explicitly set the frame of your view. Instead you are supposed to specify a set of sufficient constraints, so that the frame is automatically calculated by the layout engine.
// ------------------------------------------------------------------------------------------------------------------
// Methods to Override
//
// Initialization
//
// initWithFrame: It is recommended that you implement this method. You can also implement custom initialization methods in addition to, or instead of, this method.
// initWithCoder: Implement this method if you load your view from an Interface Builder nib file and your view requires custom initialization.
// layerClass Implement this method only if you want your view to use a different Core Animation layer for its backing store. For example, if you are using OpenGL ES to do your drawing, you would want to override this method and return the CAEAGLLayer class.
// Drawing and printing
//
// drawRect: Implement this method if your view draws custom content. If your view does not do any custom drawing, avoid overriding this method.
// drawRect:forViewPrintFormatter: Implement this method only if you want to draw your view’s content differently during printing.
// Constraints
//
// requiresConstraintBasedLayout Implement this class method if your view class requires constraints to work properly.
// updateConstraints Implement this method if your view needs to create custom constraints between your subviews.
// alignmentRectForFrame:, frameForAlignmentRect: Implement these methods to override how your views are aligned to other views.
// Layout
//
// sizeThatFits: Implement this method if you want your view to have a different default size than it normally would during resizing operations. For example, you might use this method to prevent your view from shrinking to the point where subviews cannot be displayed correctly.
// layoutSubviews Implement this method if you need more precise control over the layout of your subviews than either the constraint or autoresizing behaviors provide.
// didAddSubview:, willRemoveSubview: Implement these methods as needed to track the additions and removals of subviews.
// willMoveToSuperview:, didMoveToSuperview Implement these methods as needed to track the movement of the current view in your view hierarchy.
// willMoveToWindow:, didMoveToWindow Implement these methods as needed to track the movement of your view to a different window.
// Event Handling:
//
// touchesBegan:withEvent:, touchesMoved:withEvent:, touchesEnded:withEvent:, touchesCancelled:withEvent: Implement these methods if you need to handle touch events directly. (For gesture-based input, use gesture recognizers.)
// gestureRecognizerShouldBegin: Implement this method if your view handles touch events directly and might want to prevent attached gesture recognizers from triggering additional actions.

class TabsView: UIView {
    private var tabs:[TabView]
    public weak var delegate: TabsDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        tabs = [TabView]()
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        tabs = [TabView]()
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        
    }
    
    override func awakeFromNib() {
        
    }
}
