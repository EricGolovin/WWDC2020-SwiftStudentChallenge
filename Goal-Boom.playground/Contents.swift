import Foundation
import UIKit
import CoreGraphics
import PlaygroundSupport

class IntroductionViewController: UIViewController {
    
    let colors = [UIColor.red.cgColor, UIColor.blue.cgColor, UIColor.yellow.cgColor, UIColor.cyan.cgColor]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateUI()
    }
    
    func updateUI() {
        guard let imagePath = Bundle.main.path(forResource: "01Talk", ofType: "png"), let image = UIImage(named: imagePath) else {
            fatalError("No Image Found")
        }
        // MARK: - Instantiating UIViews
        let animationView = UIView(frame: view.bounds)
        let blurAffect = UIBlurEffect(style: .systemMaterialLight)
        let blurView = UIVisualEffectView(effect: blurAffect)
        let informationView = UIView()
        let imageView = UIImageView(image: image)
        
        // MARK: Instantiating Elements
        let backButton = UIButton(type: .custom)
        let nextButton = UIButton()
        let stackView = UIStackView(arrangedSubviews: [backButton, nextButton])
                
        // MARK: - Configuring UIViews
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        informationView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        informationView.layer.cornerRadius = 25
        
        informationView.layer.shadowColor = UIColor.white.cgColor
        informationView.layer.shadowOpacity = 1
        informationView.layer.shadowRadius = 10
        informationView.layer.shadowOffset = .zero
        
        informationView.translatesAutoresizingMaskIntoConstraints = false
        informationView.clipsToBounds = false
        
        blurView.frame = animationView.bounds
        animationView.layer.animate(colors: colors, duration: 5, sizing: animationView.bounds)
        
        // MARK: Configuring Elements
//        let buttonTitleShadow = NSShadow()
//        buttonTitleShadow.shadowColor = UIColor.black.cgColor
//        buttonTitleShadow.shadowOffset = CGSize(width: 10, height: 10)
//        buttonTitleShadow.shadowBlurRadius = 10
        backButton.setTitle("<-", for: .normal)
        backButton.backgroundColor = .white
        backButton.setAttributedTitle(NSAttributedString(string: "←", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 191/255, blue: 1, alpha: 0.5)]), for: .normal)
        backButton.setTitleShadowColor(UIColor.black, for: .normal)
        backButton.layer.shadowRadius = 10
        backButton.layer.shadowOpacity = 1
        backButton.layer.shadowOffset = .zero
        backButton.layer.shadowColor = UIColor.white.cgColor
        backButton.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        backButton.titleLabel?.layer.shadowRadius = 5
        backButton.titleLabel?.layer.opacity = 1
        backButton.titleLabel?.shadowOffset = CGSize(width: 0, height: 1)
        backButton.addTarget(self, action: #selector(backButtonPressed(_:)), for: .touchUpInside)
        
        nextButton.backgroundColor = .white
        nextButton.setTitle("Press Me!", for: .normal)
        nextButton.setAttributedTitle(NSAttributedString(string: "Next →", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 191/255, blue: 1, alpha: 0.5)]), for: .normal)
        nextButton.layer.shadowRadius = 10
        nextButton.layer.shadowOpacity = 1
        nextButton.layer.shadowOffset = .zero
        nextButton.layer.shadowColor = UIColor.white.cgColor
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.arrangedSubviews.map { button in
            button.layer.cornerRadius = 10
        }
        
        // MARK: - Addding Subviews
        informationView.addSubview(imageView)
        animationView.addSubview(blurView)
        animationView.addSubview(informationView)
        animationView.addSubview(stackView)
        self.view.addSubview(animationView)
        
        // MARK: - Configuring Layout
        let constraits = [
            informationView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 40),
            informationView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -40),
            informationView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -325),
            informationView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 40),
            stackView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -40),
            stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40),
            stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 40),
            stackView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 40),
            stackView.arrangedSubviews[0].heightAnchor.constraint(equalToConstant: 50),
            stackView.arrangedSubviews[1].heightAnchor.constraint(equalToConstant: 50),
            imageView.topAnchor.constraint(equalTo: informationView.topAnchor),
            imageView.rightAnchor.constraint(equalTo: informationView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: informationView.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: informationView.leftAnchor),
        ]
        
        NSLayoutConstraint.activate(constraits)
        
    }
    
    // Actions
    @objc func backButtonPressed(_ sender: UIButton) {
        print("BackButton Pressed")
    }
    @objc func nextButtonPressed(_ sender: UIButton) {
        print("NextButton Pressed")
        
        let configuration = ConfigurationViewController()
        
        navigationContoller.pushViewController(configuration, animated: true)
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
navigationContoller.navigationBar.isHidden = true
PlaygroundPage.current.liveView = navigationContoller


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
