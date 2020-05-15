import Foundation
import UIKit
import CoreGraphics
import PlaygroundSupport

struct DataManager {
    static func loadPlist(name: String) -> [[String: AnyObject]] {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist"), let items = NSArray(contentsOfFile: path) else {
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

enum Gender: String, CaseIterable {
    case woman
    case man
    case unspecified
}


class TableDataManger<Item> where Item: BlurCellDataProtocol {
    private var elements = Array<Item>()
    
    var elementsList: [Item] {
        elements
    }
    
    init() {
        if Item.self is RegionItem.Type {
            self.fetchRegions()
        } else if Item.self is GenderItem.Type {
            self.fetchGenders()
        } else if Item.self is OccupationItem.Type {
            self.fetchOccupations()
        } else if Item.self is HeroItem.Type {
            self.fetchHeros()
        }
    }
    
    func fetchRegions() {
        if (elements.count > 0) {
            elements.removeAll()
        }
        for data in DataManager.loadPlist(name: "Countries") {
            elements.append(RegionItem(data as! [String: String]) as! Item)
        }
    }
    
    func fetchGenders() {
        if (elements.count > 0) {
            elements.removeAll()
        }
        for gender in Gender.allCases {
            elements.append(GenderItem(gender) as! Item)
        }
    }
    
    func fetchOccupations() {
        if (elements.count > 0) {
            elements.removeAll()
        }
        for data in DataManager.loadPlist(name: "Jobs") {
            elements.append(OccupationItem(data as! [String: String]) as! Item)
        }
    }
    
    func fetchHeros() {
        if (elements.count > 0) {
            elements.removeAll()
        }
        for data in DataManager.loadPlist(name: "Heros") {
            elements.append(HeroItem(data) as! Item)
        }
    }
}

struct HeroItem: BlurCellDataProtocol {
    var images: [UIImage]
    var quotes: [String]
    var information: String
    var occupations: [String]
    var elements: [(emoji: String, title: String)]
    var gender: Gender
    
    init(_ hero: [String: AnyObject]) {
        self.elements = [(emoji: "", title: "")]
        self.quotes = []
        self.images = []
        self.occupations = []
        self.information = ""
        self.gender = .unspecified
        for (key, value) in hero {
//            print(key)
            switch key {
            case "Name":
                elements[0].emoji = value as! String
            case "Country":
                elements[0].title = value as! String
            case "Quotes":
                for quote in value as! Array<String> {
                    quotes.append(quote)
                }
            case "Image":
                if let path = Bundle.main.path(forResource: "HerosPhotos/\(value as! String)@2x", ofType: "png"), let image = UIImage(named: path) {
                    self.images.append(image)
                }
                if let path = Bundle.main.path(forResource: "HerosPhotos/\(value as! String)@3x", ofType: "png"), let image = UIImage(named: path) {
                    self.images.append(image)
                }
            case "Jobs":
                for job in value as! Array<String> {
                    occupations.append(job)
                }
            case "Info":
                self.information = value as! String
            case "Gender":
                switch value as? String {
                case "man":
                    self.gender = .man
                case "woman":
                    self.gender = .woman
                case "unspecified":
                    self.gender = .unspecified
                default:
                    fatalError("Error in plist gender section")
                }
            default:
                print(key)
            }
        }
    }
}

struct GenderItem: BlurCellDataProtocol {
    var elements: [(emoji: String, title: String)]
    
    init(_ gender: Gender) {
        self.elements = []
        switch gender {
        case .man:
            elements.append((emoji: "🚹", title: gender.rawValue))
        case .woman:
            elements.append((emoji: "🚺", title: gender.rawValue))
        case .unspecified:
            elements.append((emoji: "🚻", title: gender.rawValue))
        }
    }
}


struct OccupationItem: BlurCellDataProtocol {
    var elements: [(emoji: String, title: String)]
    
    init(_ occupation: [String: String]) {
        self.elements = []
        for (title, emoji) in occupation {
            self.elements.append(((emoji: emoji, title: title)))
        }
    }
}

struct RegionItem: BlurCellDataProtocol {
    var regionName: String
    var elements: [(emoji: String, title: String)]
    
    init(_ region: [String: String]) {
        self.elements = []
        self.regionName = ""
        for (country, flag) in region {
            if (country == "Region") {
                self.regionName = flag
            } else {
                self.elements.append((emoji: flag, title: country))
            }
        }
        elements.sort { $0.title < $1.title }
    }
}

protocol BlurCellDataProtocol {
    var elements: [(emoji: String, title: String)] { get set }
}

class IntroductionViewController: UIViewController {
    
    let colors = [UIColor.red.cgColor, UIColor.blue.cgColor, UIColor.yellow.cgColor, UIColor.cyan.cgColor]
    var imgManager = ImageManager(numberOfImages: 3)
    var bButton: UIButton!
    var nButton: UIButton!
    var screenCounter = 0
    var stackV: UIStackView!
    var regionManager = TableDataManger<RegionItem>()
    
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
        } else if screenCounter == 3 {
            let tableViewContoller = CountryTableViewController()
            tableViewContoller.regionManager = regionManager
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
    var regionManager: TableDataManger<RegionItem>!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lightBlueColor = UIColor(red: 0, green: 1, blue: 1, alpha: 0.5).cgColor
        
        if let _ = regionManager {
            
        } else {
            regionManager = TableDataManger<RegionItem>()
        }
        navigationController?.setNavigationBarHidden(true, animated: true)
        let gradientBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        gradientBackgroundView.layer.animate(colors: [lightBlueColor, UIColor.blue.cgColor, lightBlueColor, UIColor.yellow.cgColor], duration: 4.0, sizing: self.view.bounds)
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
        return regionManager.elementsList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regionManager.elementsList[section].elements.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        let label = UILabel()
        label.text = regionManager.elementsList[section].regionName
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
        let region = regionManager.elementsList[indexPath.section]
        let country = region.elements[indexPath.row]
        cell.set(emoji: country.emoji, country: country.title)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let genderViewController = GenderTableViewController()
        user = User(region: regionManager.elementsList[indexPath.section])
        genderViewController.user = user
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(genderViewController, animated: true)
    }
}

class GenderTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView?
    var user: User!
    
    var genderManager = TableDataManger<GenderItem>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        let gradientBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        gradientBackgroundView.layer.animate(colors: [UIColor.blue.cgColor, UIColor.red.cgColor, UIColor.blue.cgColor, UIColor.cyan.cgColor], duration: 4.0, sizing: self.view.bounds)
        self.tableView = UITableView()
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.backgroundColor = .white
        self.tableView?.register(BlurTableViewCell.self, forCellReuseIdentifier: "genderCell")
        
        let gestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(userSwiped(_:)))
        
        self.view.addGestureRecognizer(gestureRecogniser)
        
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        let questionLabel = UILabel()
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.text = "Choose your \ngender"
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
        view.addSubview(bottomView)
        view.addSubview(self.tableView!)
        
        if let tableView = self.tableView {
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
            tableView.isScrollEnabled = false
            let constraits = [
                topView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                topView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
                topView.heightAnchor.constraint(equalToConstant: 175),
                topView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
                tableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 0),
                tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
                tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
                tableView.heightAnchor.constraint(equalToConstant: CGFloat(self.genderManager.elementsList.count * 50)),
                questionLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 40),
                //                questionLabel.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: 0),
                questionLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -5),
                questionLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 20),
                bottomView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
                bottomView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                bottomView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                bottomView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            ]
            
            NSLayoutConstraint.activate(constraits)
        } else {
            fatalError("tableView is nil")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genderManager.elementsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "genderCell", for: indexPath) as! BlurTableViewCell
        let emoji = genderManager.elementsList[indexPath.row].elements[0].emoji
        let title = genderManager.elementsList[indexPath.row].elements[0].title
        cell.set(emoji: emoji, country: title)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = user {
            switch genderManager.elementsList[indexPath.row].elements[0].title {
            case Gender.man.rawValue:
                user.gender = .man
            case Gender.woman.rawValue:
                user.gender = .woman
            case Gender.unspecified.rawValue:
                user.gender = .unspecified
            default:
                break
            }
            
            let occupationViewController = OccupationTableViewController()
            occupationViewController.user = user
            navigationController?.pushViewController(occupationViewController, animated: true)
        } else {
            fatalError("GenderTableViewController: User is nil")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func userSwiped(_ sender: UIGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
}

class OccupationTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView?
    var user: User!
    
    var genderManager = TableDataManger<OccupationItem>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        let gradientBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        gradientBackgroundView.layer.animate(colors: [UIColor.white.cgColor, UIColor.red.cgColor, UIColor.purple.cgColor, UIColor.red.cgColor], duration: 4.0, sizing: self.view.bounds)
        self.tableView = UITableView()
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.backgroundColor = .white
        self.tableView?.register(BlurTableViewCell.self, forCellReuseIdentifier: "genderCell")
        
        let gestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(userSwiped(_:)))
        
        self.view.addGestureRecognizer(gestureRecogniser)
        
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        let questionLabel = UILabel()
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.text = "Choose your \noccupation"
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
                tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
                tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                questionLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 40),
                questionLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -5),
                questionLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 20),
            ]
            
            NSLayoutConstraint.activate(constraits)
        } else {
            fatalError("tableView is nil")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genderManager.elementsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "genderCell", for: indexPath) as! BlurTableViewCell
        let emoji: String
        if let user = user {
            emoji = genderManager.elementsList[indexPath.row].elements[0].emoji.getEmojiType(type: user.gender)
        } else {
            emoji = genderManager.elementsList[indexPath.row].elements[0].emoji.getEmojiType(type: .man)
        }
        let title = genderManager.elementsList[indexPath.row].elements[0].title
        cell.set(emoji: emoji, country: title)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func userSwiped(_ sender: UIGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
}

class HerosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var dataManager: TableDataManger<HeroItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(HeroCollectionViewCell.self, forCellWithReuseIdentifier: "heroCell")
        self.dataManager = TableDataManger<HeroItem>()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "heroCell", for: indexPath) as! HeroCollectionViewCell
        
        cell.heroImageView.image = dataManager.elementsList[0].images[0]
        cell.heroNameLabel.text = dataManager.elementsList[0].elements[0].title
        cell.heroCountryLabel.text = dataManager.elementsList[0].elements[0].emoji
        cell.heroQuoteLabel.text = dataManager.elementsList[0].quotes.first
        
        switch dataManager.elementsList[0].gender {
        case .man:
            let subCellView = cell.contentView.subviews[0]
            let cellView = cell.contentView.subviews[0].subviews[0]
            
            subCellView.backgroundColor = .white
            cellView.backgroundColor = UIColor(red: 225/255, green: 1, blue: 1, alpha: 0.5 )
        default:
            print("Ffff")
            break
        }
//        cell.heroNameLabel.text = "Hero"
//        cell.heroCountryLabel.text = "🇹🇴"
//        cell.heroQuoteLabel.text = "Be Productive!"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 150, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 15, bottom: 0, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

class HeroCollectionViewCell: UICollectionViewCell {
    var heroImageView: UIImageView!
    var heroNameLabel: UILabel!
    var heroCountryLabel: UILabel!
    var heroQuoteLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibFile = UINib(nibName: "HeroCollectionViewCell", bundle: .main)
        let nibView = nibFile.instantiate(withOwner: self, options: .none).first! as? UIView
        
        for sub in nibView!.subviews[0].subviews {
            if let imageSubview = sub as? UIImageView {
                self.heroImageView = imageSubview
                print("Found Cell imageView")
            } else if let stackViewSubview = sub as? UIStackView {
                self.heroNameLabel = (stackViewSubview.arrangedSubviews[0] as! UILabel)
                self.heroCountryLabel = (stackViewSubview.arrangedSubviews[1] as! UILabel)
            } else if let quote = sub as? UILabel {
                self.heroQuoteLabel = quote
            }
            
        }
        contentView.addSubview(nibView!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            emojiLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 40),
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
let genderViewController = GenderTableViewController()
let occupationViewController = OccupationTableViewController()
let collectionViewController = HerosCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
let navigationContoller = UINavigationController(rootViewController: collectionViewController)
navigationContoller.preferredContentSize = CGSize(width: 350, height: 700)
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
        gradient.colors = [colors[0], colors[1]]
        gradient.locations =  [-0.5, 1.5]
        
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = [colors[0], colors[1]]
        animation.toValue = [colors[2], colors[3]]
        animation.duration = duration
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        gradient.add(animation, forKey: nil)
        
        self.addSublayer(gradient)
    }
}

extension String {
    func getEmojiType(type: Gender) -> String {
        switch type {
        case .man:
            return String(self[index(self.startIndex, offsetBy: 2)])
        case .woman:
            return String(self[index(self.startIndex, offsetBy: 0)])
        case .unspecified:
            return String(self[index(self.startIndex, offsetBy: 1)])
        }
    }
}





