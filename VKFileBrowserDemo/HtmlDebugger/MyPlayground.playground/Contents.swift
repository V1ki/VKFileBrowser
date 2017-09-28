//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import CoreText
import QuartzCore

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = VKCoreTextView()
        label.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
        label.backgroundColor = .red
        
        view.addSubview(label)
        
        self.view = view
        
        label.buildFrame()
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

class VKCoreTextView : UIScrollView,UIScrollViewDelegate{
    var frames = [VKCoreItemView]()
    func buildFrame(){
        
        self.delegate = self
        let content = UIGraphicsGetCurrentContext()
        content?.textMatrix = CGAffineTransform.identity
        
        content?.translateBy(x: 0, y: self.bounds.size.height)
        
        content?.scaleBy(x: 1, y: -1)

        //绘制区域

        let mutablePath = CGMutablePath()
        let textFrame = self.bounds
        mutablePath.addRect(self.bounds)
        
        let attr = NSMutableAttributedString(string:"")
        
        //绘制文字
        let setter = CTFramesetterCreateWithAttributedString(attr)
        
        var textPos  = 0
        var columnIndex : CGFloat = 0
        
        while textPos < attr.length {
            var colOffset = CGPoint(x: 0, y: columnIndex * textFrame.size.height)
            var colRect = CGRect(x: 0, y: 0, width: textFrame.size.width, height: textFrame.size.height )
            let path = CGMutablePath()
            path.addRect(colRect)
        
            let frame = CTFramesetterCreateFrame(setter, CFRangeMake(textPos ,0), path, nil)
            let frameRange = CTFrameGetVisibleStringRange(frame)
            
            
            let itemView = VKCoreItemView(frame: CGRect(x: colOffset.x, y: colOffset.y, width: colRect.size.width, height: colRect.size.height))

            itemView.ctFrame = frame
            itemView.backgroundColor = .green
            
            self.addSubview(itemView)
            frames.append(itemView)
            
            
            textPos += frameRange.length
            
            
            columnIndex += 1
        }
        
        let totalPages = (columnIndex + 1) / 2
        
        self.contentSize = CGSize(width: self.bounds.size.width , height: self.bounds.size.height * totalPages)
        
        print(self.contentSize)
        
        
    }
}


class VKCoreItemView : UIView {
    
    var ctFrame : CTFrame?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let content = UIGraphicsGetCurrentContext()
        content?.textMatrix = CGAffineTransform.identity
        
        content?.translateBy(x: 0, y: self.bounds.size.height)
        
        content?.scaleBy(x: 1, y: -1)
        
        if let cf = ctFrame {
            CTFrameDraw(cf, content!)
        }
        
        
        

    }
}
 
