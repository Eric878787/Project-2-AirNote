//
//  DrawingViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/15.
//

import UIKit

class DrawingPadViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var sharedButton: UIButton!
    @IBOutlet weak var setUpButton: UIButton!
    @IBOutlet var pencils: [UIButton]!
    private var lastPoint = CGPoint.zero
    private var color = UIColor.black
    private var brushWidth: CGFloat = 10.0
    private var opacity: CGFloat = 1.0
    private var swiped = false
    var imageProvider: ( (UIImage) -> Void)?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(backToPreviousPage))
        configButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for pencil in pencils {
            pencil.layer.borderColor = UIColor.systemGray4.cgColor
            pencil.layer.borderWidth = 1
            pencil.layer.cornerRadius = pencil.frame.height / 2
        }
    }
    
    // MARK: Methods
    private func configButtons() {
        
        // Reset Button
        resetButton.setTitle("重畫", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.titleLabel?.font =  UIFont(name: "PingFangTC-Regular", size: 16)
        resetButton.backgroundColor = .myDarkGreen
        resetButton.layer.cornerRadius = 10
        resetButton.clipsToBounds = true
        
        // Set Up Button
        setUpButton.setTitle("設定", for: .normal)
        setUpButton.setTitleColor(.white, for: .normal)
        setUpButton.titleLabel?.font =  UIFont(name: "PingFangTC-Regular", size: 16)
        setUpButton.backgroundColor = .myDarkGreen
        setUpButton.layer.cornerRadius = 10
        setUpButton.clipsToBounds = true
        
        // Shared Button
        sharedButton.setTitle("分享", for: .normal)
        sharedButton.setTitleColor(.white, for: .normal)
        sharedButton.titleLabel?.font =  UIFont(name: "PingFangTC-Regular", size: 16)
        sharedButton.backgroundColor = .myDarkGreen
        sharedButton.layer.cornerRadius = 10
        sharedButton.clipsToBounds = true
        
    }
    
    @objc func backToPreviousPage() {
        imageProvider?(mainImageView.image ?? UIImage())
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func setUpPencil(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "DrawingPad", bundle: nil)
        guard let viewController = storyBoard.instantiateViewController(withIdentifier: "SetUpPadViewController")
                as? SetUpPadViewController else { return }
        viewController.delegate = self
        viewController.brush = brushWidth
        viewController.opacity = opacity
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        viewController.red = red
        viewController.green = green
        viewController.blue = blue
        self.navigationController?.present(viewController, animated: true)
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        mainImageView.image = nil
    }
    
    @IBAction func sharePressed(_ sender: UIButton) {
        guard let image = mainImageView.image else {
            return
        }
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = sender
        present(activity, animated: true)
    }
    
    @IBAction func pencilPressed(_ sender: UIButton) {
        guard let pencil = Pencil(tag: sender.tag) else {
            return
        }
        for pencil in pencils {
            pencil.layer.borderColor = UIColor.systemGray4.cgColor
            sender.layer.borderWidth = 1
        }
        sender.layer.borderColor = UIColor.systemGray2.cgColor
        sender.layer.borderWidth = 2
        color = pencil.color
        if pencil == .eraser {
            opacity = 1.0
        }
    }
    
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        tempImageView.image?.draw(in: view.bounds)
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(color.cgColor)
        context.strokePath()
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        swiped = false
        lastPoint = touch.location(in: view)
    }
    
    // The timing when user start to move the touch point
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        swiped = true
        let currentPoint = touch.location(in: view)
        drawLine(from: lastPoint, to: currentPoint)
        
        lastPoint = currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawLine(from: lastPoint, to: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
        tempImageView?.image?.draw(in: view.bounds, blendMode: .normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        tempImageView.image = nil
    }
}

// MARK: - SettingsViewControllerDelegate
extension DrawingPadViewController: SetUpPadViewControllerDelegate {
    func settingsViewControllerFinished(_ settingsViewController: SetUpPadViewController) {
        brushWidth = settingsViewController.brush
        opacity = settingsViewController.opacity
        color = UIColor(red: settingsViewController.red,
                        green: settingsViewController.green,
                        blue: settingsViewController.blue,
                        alpha: opacity)
        dismiss(animated: true)
    }
}
