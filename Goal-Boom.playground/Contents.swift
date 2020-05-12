import Foundation
import UIKit
import CoreGraphics
import PlaygroundSupport

class IntroductionViewController: UIViewController {
    
    let colors = [UIColor.red.cgColor, UIColor.blue.cgColor, UIColor.yellow.cgColor, UIColor.cyan.cgColor]
    var imgManager = ImageManager(numberOfImages: 3)
    var bButton: UIButton!
    var nButton: UIButton!
    var screenCounter = 0
    var stackV: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    func updateUI() {
        guard let image = imgManager.getFirstImage() else {
            fatalError("No Image Found")
        }
        // MARK: - Instantiating UIViews
        let animationView = UIView(frame: view.bounds)
        let imageView = UIImageView(image: image)
        let blurAffect = UIBlurEffect(style: .systemMaterialLight)
        let blurView = UIVisualEffectView(effect: blurAffect)
        let informationView = UIView()
        
        
        // MARK: Instantiating Elements
        let backButton = UIButton(type: .custom)
        let nextButton = UIButton()
        let stackView = UIStackView(arrangedSubviews: [backButton, nextButton])
        
        // MARK: - Configuring UIViews
        imageView.tag = 100
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
        backButton.isHidden = true
        bButton = backButton
        
        nextButton.backgroundColor = .white
        nextButton.setTitle("Press Me!", for: .normal)
        nextButton.setAttributedTitle(NSAttributedString(string: "Next →", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 191/255, blue: 1, alpha: 0.5)]), for: .normal)
        nextButton.layer.shadowRadius = 10
        nextButton.layer.shadowOpacity = 1
        nextButton.layer.shadowOffset = .zero
        nextButton.layer.shadowColor = UIColor.white.cgColor
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        nButton = nextButton
        
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.arrangedSubviews.map { button in
            button.layer.cornerRadius = 10
        }
        stackV = stackView
        
        // MARK: - Addding Subviews
        
        animationView.addSubview(blurView)
        animationView.addSubview(informationView)
        self.view.addSubview(animationView)
        self.view.addSubview(imageView)
        self.view.addSubview(stackView)
        
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
            imageView.rightAnchor.constraint(equalTo: informationView.rightAnchor, constant: -5),
            imageView.bottomAnchor.constraint(equalTo: informationView.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: informationView.leftAnchor, constant: 5),
        ]
        
        NSLayoutConstraint.activate(constraits)
        
    }
    
    // MARK: - Actions
    @objc func backButtonPressed(_ sender: UIButton) {
        print("BackButton Pressed")
        for subview in view.subviews {
            if (subview.tag == 100) {
                let imageView = (subview as! UIImageView)
                if let image = imgManager.getImage(next: false) {
//                    UIView.animate(withDuration: 5) {
//                        imageView.image = image
//                    }
                    UIView.transition(with: imageView, duration: 0.75, options: .transitionCrossDissolve, animations: {
                        imageView.image = image
                        
                    }, completion: nil)
                } else {
                    print("Theare No images left")
                }
                
            }
            
        }
        if screenCounter - 1 != -1  {
            screenCounter -= 1
        }
        if screenCounter == 0 || screenCounter == 2 {
            bButton.isHidden = true
        } else {
            bButton.isHidden = false
        }

    }
    
    @objc func nextButtonPressed(_ sender: UIButton) {
        print("NextButton Pressed")
        for subview in view.subviews {
            if (subview.tag == 100) {
                let imageView = (subview as! UIImageView)
                if let image = imgManager.getImage(next: true) {
//                    UIView.animate(withDuration: 5) {
//                        imageView.image = image
//                    }
                    UIView.transition(with: imageView, duration: 0.75, options: .transitionCrossDissolve, animations: {
                        imageView.image = image
                        
                    }, completion: nil)
                } else {
                    print("There No images left")
                }
            }
        }
        print(screenCounter)
        if screenCounter + 1 != imgManager.imageCount {
            screenCounter += 1
        }
        if screenCounter == 0  {
            bButton.isHidden = true
        } else if screenCounter == 2 {
            if bButton.isHidden == true {
                let configuration = ConfigurationViewController()
                navigationController?.pushViewController(configuration, animated: true)
            }
            bButton.isHidden = true
            
            nButton.backgroundColor = UIColor(red: 0, green: 191/255, blue: 1, alpha: 0.5)
            nButton.setAttributedTitle(NSAttributedString(string: "Motivate Yourself", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]), for: .normal)
        } else {
            bButton.isHidden = false
        }
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


final class ImageManager {
    var arrayOfImages = [UIImage]()
    private var imageCounter = 0
    
    var imageCount: Int {
        arrayOfImages.count
    }
    
    init(numberOfImages: Int) {
        for i in 0...numberOfImages {
            if let imagePath = Bundle.main.path(forResource: "Talk" + String(i), ofType: "png"), let image = UIImage(named: imagePath) {
                arrayOfImages.append(image)
            }
        }
    }
    
    func getImage(next: Bool) -> UIImage? {
        if arrayOfImages.count != 0 && next {
            if imageCounter == 0 {
                imageCounter = 1
            }
            let resultImage = arrayOfImages[imageCounter]
            if imageCounter + 1 != arrayOfImages.count {
                imageCounter = imageCounter + 1
            }
            print("increase \(imageCounter)")
            return resultImage
        } else if !next {
            
            if imageCounter - 1 != -1 {
                imageCounter = imageCounter - 1
            }
            let resultImage = arrayOfImages[imageCounter]
            print("decrease \(imageCounter)")
            return resultImage
        }
        return nil
    }
    
    func getFirstImage() -> UIImage? {
        if arrayOfImages.count != 0 {
            let resultImage = arrayOfImages[imageCounter]
            if imageCounter + 1 != arrayOfImages.count {
                imageCounter = imageCounter + 1
            }
            print("increase \(imageCounter)")
            return resultImage
        }
        return nil
    }
}

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
