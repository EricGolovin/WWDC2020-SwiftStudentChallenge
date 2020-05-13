import Foundation
import UIKit
import CoreGraphics
import PlaygroundSupport

struct DataManager {
    static func load() -> [[String: AnyObject]] {
        guard let path = Bundle.main.path(forResource: "Countries", ofType: "plist"), let items = NSArray(contentsOfFile: path) else {
            return [[:]]
        }
        return items as! [[String: AnyObject]]
    }
}

class User {
    var gender: Gender
    var region: RegionItem
    
    init(gender: Gender, region: RegionItem) {
        self.gender = gender
        self.region = region
    }
    
    convenience init(region: RegionItem) {
        self.init(gender: .unspecified, region: region)
    }
}

enum Gender: String {
    case woman
    case man
    case unspecified
}

class RegionDataManger {
    private var regions = Array<RegionItem>()
    
    var regionList: [RegionItem] {
        regions
    }
    
    func fetch() {
        if (regions.count > 0) {
            regions.removeAll()
        }
        for data in DataManager.load() {
            regions.append(RegionItem(data as! [String: String]))
        }
    }
}

struct RegionItem {
    var regionName = ""
    var countries = [String]()
    var flags = [String]()
    
    init(_ region: [String: String]) {
        for (country, flag) in region {
            if (country == "Region") {
                self.regionName = flag
            } else {
                countries.append(country)
                flags.append(flag)
            }
        }
    }
}

class IntroductionViewController: UIViewController {
    
    let colors = [UIColor.red.cgColor, UIColor.blue.cgColor, UIColor.yellow.cgColor, UIColor.cyan.cgColor]
    var imgManager = ImageManager(numberOfImages: 3)
    var bButton: UIButton!
    var nButton: UIButton!
    var screenCounter = 0
    var stackV: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
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
        } else if screenCounter == 3 {
            screenCounter = 1
        }
        if screenCounter == 0 || screenCounter == 2 {
            bButton.isHidden = true
        } else {
            changeNButtonColor()
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
        if screenCounter + 1 <= imgManager.imageCount {
            screenCounter += 1
        }
        if screenCounter == 0  {
            bButton.isHidden = true
        } else if screenCounter == 2 {
            changeNButtonColor()
        } else             if screenCounter == 3 {
            let tableViewContoller = CountryTableViewController()
            navigationController?.pushViewController(tableViewContoller, animated: true)
        
    } else {
            changeNButtonColor()
            bButton.isHidden = false
        }
    }
    
    func changeNButtonColor() {
        if screenCounter == 2 {
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.autoreverse], animations: {
            self.nButton.backgroundColor = UIColor(red: 0, green: 191/255, blue: 1, alpha: 0.7)
            self.nButton.backgroundColor = UIColor(red: 1, green: 192/255, blue: 203/255, alpha: 0.7)
        }, completion: { _ in
            self.nButton.backgroundColor = UIColor(red: 0, green: 191/255, blue: 1, alpha: 0.7)
        })
            nButton.setAttributedTitle(NSAttributedString(string: "Motivate Yourself", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]), for: .normal)
        } else {
            nButton.backgroundColor = .white
             nButton.setAttributedTitle(NSAttributedString(string: "Next →", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 191/255, blue: 1, alpha: 0.5)]), for: .normal)
        }
    }
}

class CountryTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView?
    var regionManager = RegionDataManger()
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lightBlueColor = UIColor(red: 0, green: 1, blue: 1, alpha: 0.5).cgColor
        let darkBlueColor = UIColor(red: 65 / 255, green: 105 / 255, blue: 225 / 255, alpha: 0.5).cgColor
        
        regionManager.fetch()
        navigationController?.setNavigationBarHidden(true, animated: true)
        let gradientBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        gradientBackgroundView.layer.animate(colors: [lightBlueColor, UIColor.blue.cgColor, lightBlueColor, darkBlueColor], duration: 2.0, sizing: self.view.bounds)
        self.tableView = UITableView()
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.backgroundColor = .white
        self.tableView?.register(BlurTableViewCell.self, forCellReuseIdentifier: "countryCell")
        
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        
        let questionLabel = UILabel()
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.text = "Choose your \ncountry"
        questionLabel.textColor = .white
        questionLabel.numberOfLines = 0
        questionLabel.font = UIFont(name: "Kefa", size: 40)
        questionLabel.adjustsFontSizeToFitWidth = true
        questionLabel.backgroundColor = .clear
        
        questionLabel.layer.shadowColor = UIColor.black.cgColor
        questionLabel.layer.shadowRadius = 10
        questionLabel.layer.shadowOffset = .zero
        questionLabel.layer.shadowOpacity = 0.3
        
                
        view.addSubview(gradientBackgroundView)
        topView.addSubview(questionLabel)
        view.addSubview(topView)
        view.addSubview(self.tableView!)
        
        if let tableView = self.tableView {
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
            let constraits = [
                topView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                topView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
                topView.heightAnchor.constraint(equalToConstant: 175),
                topView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
                tableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 0),
                tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
                tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
                tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
                questionLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 40),
//                questionLabel.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: 0),
                questionLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -5),
                questionLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 20),
            ]
            
            NSLayoutConstraint.activate(constraits)
        } else {
            fatalError("tableView is nil")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return regionManager.regionList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regionManager.regionList[section].countries.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        let label = UILabel()
        label.text = regionManager.regionList[section].regionName
        label.textColor =  UIColor(red: 0.496, green: 0.496, blue: 0.496, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(label)

        let constaits = [
            label.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
        ]

        NSLayoutConstraint.activate(constaits)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath) as! BlurTableViewCell
        let region = regionManager.regionList[indexPath.section]
        let countryName = region.countries[indexPath.row]
        let countryFlag = region.flags[indexPath.row]
        cell.set(emoji: countryFlag, country: countryName)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        user = User(region: regionManager.regionList[indexPath.section])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class BlurTableViewCell: UITableViewCell {
    
    private var emojiLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont(name: "Helvetica", size: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 7
        label.layer.shadowOffset = .zero
        label.layer.shadowOpacity = 0.3
        
        return label
    }()
    
    private var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica", size: 17)
        label.textColor = UIColor(red: 0.496, green: 0.496, blue: 0.496, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(infoLabel)

        
        let constaits = [
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            emojiLabel.widthAnchor.constraint(equalToConstant: 50),
            infoLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            infoLabel.leftAnchor.constraint(equalTo: emojiLabel.leftAnchor, constant: 60),
        ]
        
        NSLayoutConstraint.activate(constaits)
    }
    
    func set(emoji: String, country: String) {
        emojiLabel.text = emoji
        infoLabel.text = country
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

let master = IntroductionViewController()
let tableViewContoller = CountryTableViewController()
let navigationContoller = UINavigationController(rootViewController: master)
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
    func animate(colors: [CGColor], duration: Double, sizing: CGRect) {
        let gradient = CAGradientLayer()
        gradient.frame = sizing
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.colors = [UIColor.red.cgColor, UIColor.green.cgColor]
        gradient.locations =  [-0.5, 1.5]
        
        let animation = CABasicAnimation(keyPath: "colors")
//        if let colors = colors, colors.count > 4 {
            animation.fromValue = [colors[0], colors[1]]
            animation.toValue = [colors[2], colors[3]]
//        } else {
//            animation.fromValue = [UIColor.red.cgColor, UIColor.blue.cgColor]
//            animation.toValue = [UIColor.yellow.cgColor, UIColor.cyan.cgColor]
//        }
        animation.duration = 5.0
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        gradient.add(animation, forKey: nil)
        
        self.addSublayer(gradient)
    }
}





