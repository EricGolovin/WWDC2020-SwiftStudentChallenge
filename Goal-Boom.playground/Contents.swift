import Foundation
import UIKit
import CoreGraphics
import PlaygroundSupport

class IntroductionViewController: UIViewController {
    
    
    let configurationViewContoller = ConfigurationViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateUI()
    }
    
    func updateUI() {
        let button = UIButton()
        
        let animationView = UIView(frame: view.bounds)
        let blurAffect = UIBlurEffect(style: .systemMaterialLight)
        let blurView = UIVisualEffectView(effect: blurAffect)
        
        //        let frameX = animationView.frame.maxX / 10
        //        let frameY = animationView.frame.maxY / 10
        let informationView = UIView() // frame: CGRect(x: frameX, y: frameY, width:CGFloat(animationView.frame.maxX - frameX * 2), height: animationView.frame.height / 2)
        
        //        button.center.x = view.frame.width/2
        //        button.center.y = view.frame.height/2
        button.backgroundColor = .white
        button.setTitle("Press Me!", for: .normal)
//        button.setAttributedTitle(NSAttributedString(string: "Press Me!", attributes: [NSAttributedStringKey: ]), for: <#T##UIControl.State#>)
//        button.sizeToFit()
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        informationView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        informationView.layer.cornerRadius = 25
        
        blurView.frame = animationView.bounds
        
        let colors = [UIColor.red.cgColor, UIColor.blue.cgColor, UIColor.yellow.cgColor, UIColor.cyan.cgColor]
        animationView.layer.animate(colors: colors, duration: 5, sizing: animationView.bounds)
        animationView.addSubview(blurView)
        
        
        self.view.addSubview(animationView)
        informationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.addSubview(informationView)
        
        informationView.addSubview(button)
        informationView.clipsToBounds = false
        
        let backButton = UIButton(type: .custom)
        backButton.setTitle("<-", for: .normal)
        backButton.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [backButton, button])
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        animationView.addSubview(stackView)
        
        stackView.arrangedSubviews.map { button in
            button.layer.cornerRadius = 10
//            button.setAtt
        }
        
        
        let constraits = [
            informationView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 40),
            informationView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -40),
            informationView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -300),
            informationView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 40),
            stackView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -40),
                         stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40),
            stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 40),
            stackView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 40),

        ]
        
        NSLayoutConstraint.activate(constraits)
        
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        print("Button Pressed")
        
        let configuration = ConfigurationViewController()
        //        navigationController?.pushViewController(configuration, animated: true)
        PlaygroundPage.current.liveView = configuration
    }
    
    
    
}

class ConfigurationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        updateUI()
    }
    
    func updateUI() {
        let label = UILabel()
        
        label.text = "Segue Was Made"
        label.center = self.view.center
        
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        print("Button Pressed")
    }
    
    
    
}

let master = IntroductionViewController()
let navigationContoller = UINavigationController(rootViewController: master)
PlaygroundPage.current.liveView = master


extension CALayer {
    func animate(colors: [CGColor]?, duration: Double, sizing: CGRect) {
        let gradient = CAGradientLayer()
        gradient.frame = sizing
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.colors = [UIColor.red.cgColor, UIColor.green.cgColor]
        gradient.locations =  [-0.5, 1.5]
        
        let animation = CABasicAnimation(keyPath: "colors")
        if let colors = colors, colors.count > 4 {
            animation.fromValue = [colors[0], colors[1]]
            animation.toValue = [colors[2], colors[3]]
            
        } else {
            animation.fromValue = [UIColor.red.cgColor, UIColor.blue.cgColor]
            animation.toValue = [UIColor.yellow.cgColor, UIColor.cyan.cgColor]
        }
        animation.duration = 5.0
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        gradient.add(animation, forKey: nil)
        
        self.addSublayer(gradient)
    }
}
