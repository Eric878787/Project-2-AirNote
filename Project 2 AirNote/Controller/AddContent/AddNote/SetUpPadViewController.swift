//
//  DrawingPadViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/15.
//

import UIKit

protocol SetUpPadViewControllerDelegate: AnyObject {
    func settingsViewControllerFinished(_ settingsViewController: SetUpPadViewController)
}

class SetUpPadViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var sliderBrush: UISlider!
    @IBOutlet weak var sliderOpacity: UISlider!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var labelBrush: UILabel!
    @IBOutlet weak var labelOpacity: UILabel!
    @IBOutlet weak var sliderRed: UISlider!
    @IBOutlet weak var sliderGreen: UISlider!
    @IBOutlet weak var sliderBlue: UISlider!
    @IBOutlet weak var labelRed: UILabel!
    @IBOutlet weak var labelGreen: UILabel!
    @IBOutlet weak var labelBlue: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    var brush: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    weak var delegate: SetUpPadViewControllerDelegate?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sliderBrush.value = Float(brush)
        labelBrush.text = String(format: "%.1f", brush)
        sliderOpacity.value = Float(opacity)
        labelOpacity.text = String(format: "%.1f", opacity)
        sliderRed.value = Float(red * 255.0)
        labelRed.text = Int(sliderRed.value).description
        sliderGreen.value = Float(green * 255.0)
        labelGreen.text = Int(sliderGreen.value).description
        sliderBlue.value = Float(blue * 255.0)
        labelBlue.text = Int(sliderBlue.value).description
        drawPreview()
        closeButton.tintColor = .myDarkGreen
    }
    
    // MARK: Methods
    @IBAction func closePressed(_ sender: Any) {
        delegate?.settingsViewControllerFinished(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func brushChanged(_ sender: UISlider) {
        brush = CGFloat(sender.value)
        labelBrush.text = String(format: "%.1f", brush)
        drawPreview()
    }
    
    @IBAction func opacityChanged(_ sender: UISlider) {
        opacity = CGFloat(sender.value)
        labelOpacity.text = String(format: "%.1f", opacity)
        drawPreview()
    }
    
    @IBAction func colorChanged(_ sender: UISlider) {
        red = CGFloat(sliderRed.value / 255.0)
        labelRed.text = Int(sliderRed.value).description
        green = CGFloat(sliderGreen.value / 255.0)
        labelGreen.text = Int(sliderGreen.value).description
        blue = CGFloat(sliderBlue.value / 255.0)
        labelBlue.text = Int(sliderBlue.value).description
        drawPreview()
    }
    
    func drawPreview() {
        UIGraphicsBeginImageContext(previewImageView.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setLineCap(.round)
        context.setLineWidth(brush)
        context.setStrokeColor(UIColor(red: red, green: green, blue: blue, alpha: opacity).cgColor)
        let center = CGPoint(x: previewImageView.frame.width / 2, y: previewImageView.frame.height / 2)
        print("\(center)")
        context.move(to: center)
        context.addLine(to: center)
        context.strokePath()
        previewImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
}
