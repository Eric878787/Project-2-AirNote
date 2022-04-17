//
//  DrawingViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/4/15.
//

import UIKit

class DrawingPadViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    var lastPoint = CGPoint.zero
    var color = UIColor.black
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    var imageProvider: ( (UIImage) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName:"checkmark"), style: .plain, target: self, action: #selector(backToPreviousPage))
    }
    
    // MARK: - Actions
    @objc func backToPreviousPage() {
        imageProvider?(mainImageView.image ?? UIImage())
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func setUpPencil(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "DrawingPad", bundle: nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "SetUpPadViewController") as? SetUpPadViewController else { return }
        vc.delegate = self
        vc.brush = brushWidth
        vc.opacity = opacity
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        vc.red = red
        vc.green = green
        vc.blue = blue
        self.navigationController?.present(vc, animated: true)
    }
    
    @IBAction func resetPressed(_ sender: Any) {
      mainImageView.image = nil
    }
    
    @IBAction func sharePressed(_ sender: Any) {
      guard let image = mainImageView.image else {
        return
      }
      let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
      present(activity, animated: true)
    }
    
    @IBAction func pencilPressed(_ sender: UIButton) {
      guard let pencil = Pencil(tag: sender.tag) else {
        return
      }
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
