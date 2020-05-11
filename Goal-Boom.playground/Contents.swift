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
        let button = UIButton(type: .custom)
        
        button.center = view.center
        button.backgroundColor = .blue
        button.setTitle("Press Me!", for: .normal)
        button.sizeToFit()
        //        button.center.x = view.bounds.width / 2
        //        button.center.y = view.frame.height / 2
        
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        let animationView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        let blurAffect = UIBlurEffect(style: .systemMaterialLight)
        let blurView = UIVisualEffectView(effect: blurAffect)
        blurView.frame = animationView.bounds
        
        
        
        self.view.addSubview(animationView)
        animationView.addSubview(blurView)
        self.view.addSubview(button)
        
        UIView.animate(withDuration: 2, delay: 0, options: [.repeat, .autoreverse], animations: {
            animationView.backgroundColor = .red
            animationView.backgroundColor = .blue
            animationView.backgroundColor = .green
            animationView.backgroundColor = .yellow
        }, completion: nil)
//        UIView.animate(withDuration: 1) {
//            visualEffectView.effect = UIBlurEffect(style: .dark)
//        }
        
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
