

import UIKit
import Foundation
import QuartzCore


//MARK: - UIView
public extension UIView{
    ///Add custom constraints using custom format to multiable views.
    func addConstraintsWithFormatToMuliableViews(_ format:String, views:UIView...) {
        var viewsDictionary = [String:AnyObject]()
        for (index,view) in views.enumerated() {
            view.translatesAutoresizingMaskIntoConstraints = false
            let key = "v\(index)"
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func addConstraintsWithFormatToMultiableViewsWithOptions(_ format:String,options: NSLayoutFormatOptions, views:UIView...) {
        var viewsDictionary = [String:AnyObject]()
        for (index,view) in views.enumerated() {
            view.translatesAutoresizingMaskIntoConstraints = false
            let key = "v\(index)"
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: options, metrics: nil, views: viewsDictionary))
    }
    
    func roundCorners(by radius: CGFloat, at corners: UIRectCorner) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}


//MARK : - UIColor
public extension UIColor{
    //Flat Material Color
    class func triq()->UIColor{
        return hexColor(rgbValue: 0x1abc9c)
    }
    class func triqDark()->UIColor{
        return hexColor(rgbValue: 0x16a085)
    }
    class func yellow()->UIColor{
        return hexColor(rgbValue: 0xf1c40f)
    }
    class func yellowDark()->UIColor{
        return hexColor(rgbValue: 0xf39c12)
    }
    class func green()->UIColor{
        return hexColor(rgbValue: 0x84C73C)
    }
    class func greenDark()->UIColor{
        return hexColor(rgbValue: 0x66B01B)
    }
    class func orange()->UIColor{
        return hexColor(rgbValue: 0xE1A239)
    }
    class func orangeDark()->UIColor{
        return hexColor(rgbValue: 0xD88F1E)
    }
    class func blue()->UIColor{
        return hexColor(rgbValue: 0x3498db)
    }
    class func blueDark()->UIColor{
        return hexColor(rgbValue: 0x2980b9)
    }
    class func red()->UIColor{
        return hexColor(rgbValue: 0xe74c3c)
    }
    class func redDark()->UIColor{
        return hexColor(rgbValue: 0xc0392b)
    }
    class func pan()->UIColor{
        return hexColor(rgbValue: 0x9b59b6)
    }
    class func panDark()->UIColor{
        return hexColor(rgbValue: 0x8e44ad)
    }
    class func grey()->UIColor{
        return hexColor(rgbValue: 0xecf0f1)
    }
    class func greyDark()->UIColor{
        return hexColor(rgbValue: 0xbdc3c7)
    }
    class func king()->UIColor{
        return hexColor(rgbValue: 0x34495e)
    }
    class func kingDark()->UIColor{
        return hexColor(rgbValue: 0x2c3e50)
    }
    class func pink()->UIColor{
        return hexColor(rgbValue: 0xD545A9)
    }
    class func pinkDark()->UIColor{
        return hexColor(rgbValue: 0xBB268E)
    }
    
    class func lightBlue()->UIColor{
        return hexColor(rgbValue: 0xF4F9FF)
    }
    
    class func coolBlue()->UIColor{
        return hexColor(rgbValue: 0x9594E5)
    }
    
    class func coolRed()->UIColor{
        return hexColor(rgbValue: 0xFEA8A9)
    }
    
    class func coolPurple()->UIColor{
        return hexColor(rgbValue: 0xE1CCFF)
    }
    
    class func hexColor(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}


//MARK: - UIImage
public extension UIImage{
    enum Asset: String {
        case gripOn = "GripperIconOn.png"
        case gripOff = "GripperIconOff.png"
        case shotOn = "BallIconOn.png"
        case shotOff = "BallIconOff.png"
        case grip = "GripIcon.png"
        case releaseGrip = "ReleaseIcon.png"
        case shot = "ShotIcon.png"
        case releaseShot = "ReleaseShotIcon.png"
        case controlTitle = "TopTitle.png"
        case accelerometerTitle = "TopTitleAccelerometer.png"
        case accelerometer = "AccelerometerIcon.png"
        case control = "ControlIcon.png"
        case robot = "robot.png"
        case on = "OnButton.png"
        case off = "OffButton.png"
        case topArrow = "TopArrowIcon.png"
        case downArrow = "DownArrowIcon.png"
        case rightArrow = "RightArrowIcon.png"
        case leftArrow = "LeftArrowIcon.png"
        var image: UIImage {
            return UIImage(asset: self)
        }
    }
    convenience init!(asset: Asset) {
        self.init(named: asset.rawValue)
    }
}


//to convert from radian to degree
extension Double{
    mutating func toDegree() -> Double{
        return self * 180 / Double.pi
    }
}

//MARK: - UIButton
extension UIButton{
    ///Set the corner radius to full rounded
    func roundedCorner(){
        self.layer.cornerRadius = self.frame.height * 0.5
    }
    ///Helper function to generate custom button very quick :)
    func generateButton(
        frame:CGRect,
        title:String,
        titleColor: UIColor?,
        backgroundColor:UIColor?,
        borderWidth:CGFloat?,
        borderColor:UIColor?,
        cornerRadius:CGFloat?,
        fullRounded: Bool,
        font:UIFont?,
        fontSize:CGFloat?,
        action:Selector?
        ) -> UIButton{
        let customButton = UIButton(frame: frame)
        if fullRounded {
            customButton.roundedCorner()
        }else{
            customButton.layer.cornerRadius = cornerRadius ?? 0
        }
        customButton.setTitle(title, for: .normal)
        customButton.setTitleColor(titleColor ?? .king(), for: .normal)
        customButton.backgroundColor = backgroundColor ?? UIColor.white
        customButton.layer.borderWidth = borderWidth ?? 0
        customButton.layer.borderColor = borderColor?.cgColor ?? UIColor.clear.cgColor
        customButton.titleLabel?.font = font
        if (action != nil){
            customButton.addTarget(self, action: action!, for: .touchUpInside)
        }
        return customButton
    }
}

enum Buttons {
    case onButton, offButton, shotButton, releaseShotButton, gripButton, releaseGripButton, topArrowButton, downArrowButton, rightArrowButton, leftArrowButton, movementCancel
}

extension UserDefaults {
    func set(Code code:String, forButton button: Buttons){
        set(code, forKey: "\(button)")
        synchronize()
    }
    
    func getCodeOf(Button button: Buttons) -> String?{
        return string(forKey: "\(button)")
    }
}
