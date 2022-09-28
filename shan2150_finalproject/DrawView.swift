//
//  DrawView.swift
//  shan2150_finalproject
//
//  Created by 。。。。。。。 on 2021/4/9.
//

import UIKit

fileprivate class DrawBezierPath: UIBezierPath {
    public var color: UIColor
    
    init(color: UIColor, lineWidth: CGFloat, startPoint: CGPoint) {
        self.color = color
        super.init()
        self.lineWidth = 2
        lineJoinStyle = .round
        lineCapStyle = .round
        move(to: startPoint)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DrawView: UIView {
    
    public var lineColor: UIColor = .black
    
    public var lineWidth: CGFloat = 2

    /// Save All Path
    fileprivate var paths:[DrawBezierPath] = []
    
    /// Save last path
    fileprivate var lastPath: DrawBezierPath? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            lastPath = DrawBezierPath(color: lineColor, lineWidth: lineWidth, startPoint: point)
            paths.append(lastPath!)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self), let path = lastPath {
            path.addLine(to: point)
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPath = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPath = nil
    }
    
    /// Draw Path
    override func draw(_ rect: CGRect) {
        if paths.count == 0 {
            return
        }
        for item in paths {
            item.color.set()
            item.stroke()
        }
    }
    
    /// Clean Draw View
    public func clean() {
        paths = []
        setNeedsDisplay()
    }
    
    /// Get View Image
    /// - Returns: UIImage
    public func quickImage() -> UIImage? {
        if paths.count == 0 {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        var resultImage: UIImage? = nil
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            resultImage = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return resultImage
    }
}
