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
    var occupation: Occupation
    
    init(gender: Gender, region: RegionItem, occupation: Occupation) {
        self.gender = gender
        self.region = region
        self.occupation = occupation
    }
    
    convenience init(region: RegionItem) {
        self.init(gender: .unspecified, region: region, occupation: .developer)
    }
}

enum Gender: String, CaseIterable {
    case woman
    case man
    case unspecified
}

enum Occupation: String, CaseIterable {
    case engineer = "Engineer"
    case entrepreneur = "Entrepreneur"
    case doctor = "Doctor"
    case chef = "Chef"
    case investor = "Investor"
    case singer = "Singer"
    case developer = "Developer"
    case lawyer = "Lawyer"
    case inventor = "Inventor"
    case scientist = "Scientist"
    case artist = "Artist"
    case pilot = "Pilot"
    case astronaut = "Astronaut"
}


class TableDataManger<Item> where Item: BlurCellDataProtocol {
    private var elements = Array<Item>()
    
    var elementsList: [Item] {
        elements
    }
    
    init(gender: Gender = .unspecified, occupation: Occupation = .developer, country: String = "") {
        if Item.self is RegionItem.Type {
            self.fetchRegions()
        } else if Item.self is GenderItem.Type {
            self.fetchGenders()
        } else if Item.self is OccupationItem.Type {
            self.fetchOccupations()
        } else if Item.self is HeroItem.Type {
            self.fetchHeros(gender: gender, occupation: occupation, region: country)
        }
    }
    
    func fetchRegions() {
        if (elements.count > 0) {
            elements.removeAll()
        }
        for data in DataManager.loadPlist(name: "Countries") {
            elements.append(RegionItem(data as! [String: String]) as! Item)
        }
        if Item.self is RegionItem.Type {
            elements.sort { ($0 as? RegionItem)!.regionName < ($1 as? RegionItem)!.regionName }
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
    
    func fetchHeros(gender: Gender, occupation: Occupation, region: String) {
        if (elements.count > 0) {
            elements.removeAll()
        }
        for data in DataManager.loadPlist(name: "Heroes") {
            var checker = 0
            for (key, value) in data {
                switch key.lowercased() {
                case "gender":
                    if gender != .unspecified {
                        if let heroGender = value as? String, heroGender == gender.rawValue {
                            checker += 1
                        }
                    } else {
                        checker += 1
                    }

                case "jobs":
                    for job in value as! Array<String> {
                        if job == occupation.rawValue.lowercased() {
                            checker += 1
                        }
                    }
                case "country":
                    let countryComponents = (value as! String).components(separatedBy: " ")
                    if countryComponents[2].lowercased() == region.lowercased() {
                        checker += 1
                    }
                default:
                    break
                }
            }
            if checker == 3 {
                elements.append(HeroItem(data) as! Item)
            }
        }
    }
}


struct HeroItem: BlurCellDataProtocol {
    var name: String
    var image: (small: UIImage, large: UIImage)
    var quotes: [String]
    var information: String
    var occupations: [Occupation]
    var elements: [(emoji: String, title: String)]
    var gender: Gender
    
    init(_ hero: [String: AnyObject]) {
        self.name = ""
        self.elements = [(emoji: "", title: "")]
        self.quotes = []
        self.image = (small: UIImage(), large: UIImage())
        self.occupations = []
        self.information = ""
        self.gender = .unspecified
        for (key, value) in hero {
            //            print(key)
            switch key {
            case "Name":
                name = value as! String
            case "Country":
                let regionComponents = (value as! String).components(separatedBy: " ")
                elements[0].emoji = regionComponents[1]
                elements[0].title = regionComponents[0]
            case "Quotes":
                for quote in value as! Array<String> {
                    quotes.append(quote)
                }
            case "Image":
                if let path = Bundle.main.path(forResource: "HerosPhotos/\(value as! String)@2x", ofType: "png"), let image = UIImage(named: path) {
                    self.image.small = image
                } else if let path = Bundle.main.path(forResource: "HerosPhotos/\(value as! String)@2x", ofType: "jpg"), let image = UIImage(named: path) {
                    self.image.small = image
                }
                
                if let path = Bundle.main.path(forResource: "HerosPhotos/\(value as! String)@3x", ofType: "png"), let image = UIImage(named: path) {
                    self.image.large = image
                } else if let path = Bundle.main.path(forResource: "HerosPhotos/\(value as! String)@3x", ofType: "jpg"), let image = UIImage(named: path) {
                    self.image.large = image
                }
            case "Jobs":
                for job in value as! Array<String> {
                    switch job.lowercased() {
                    case "engineer":
                        self.occupations.append(.engineer)
                    case "entrepreneur":
                        self.occupations.append(.entrepreneur)
                    case "doctor":
                        self.occupations.append(.doctor)
                    case "chef":
                        self.occupations.append(.chef)
                    case "investor":
                        self.occupations.append(.inventor)
                    case "singer":
                        self.occupations.append(.singer)
                    case "developer":
                        self.occupations.append(.developer)
                    case "lawyer":
                        self.occupations.append(.lawyer)
                    case "inventor":
                        self.occupations.append(.inventor)
                    case "scientist":
                        self.occupations.append(.scientist)
                    case "artist":
                        self.occupations.append(.artist)
                    case "pilot":
                        self.occupations.append(.pilot)
                    case "astronaut":
                        self.occupations.append(.astronaut)
                    default:
                        print("Error in job title: No such job names \(job)")
                    }
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
        let data = imgManager.getFirstImage()
        guard let image = data.image, let detail = data.detail else {
            fatalError("No image or detailText found")
        }
        
        // MARK: - Instantiating UIViews
        let animationView = UIView(frame: view.bounds)
        let imageView = UIImageView(image: image)
        let blurAffect = UIBlurEffect(style: .systemMaterialLight)
        let blurView = UIVisualEffectView(effect: blurAffect)
        let informationView = UIView()
        
        
        // MARK: Instantiating Elements
        let detailLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
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
        
        detailLabel.textColor = .white
        detailLabel.font = UIFont(name: "Helvetica-Bold", size: 25)
        detailLabel.numberOfLines = 2
        detailLabel.text = detail
        detailLabel.tag = 200
        detailLabel.backgroundColor = .clear
        detailLabel.textAlignment = .center
        detailLabel.layer.shadowRadius = 10
        detailLabel.layer.shadowOpacity = 1
        detailLabel.layer.shadowOffset = .zero
        detailLabel.layer.shadowColor = UIColor.white.cgColor
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - Addding Subviews
        
        animationView.addSubview(blurView)
        animationView.addSubview(informationView)
        self.view.addSubview(animationView)
        self.view.addSubview(imageView)
        self.view.addSubview(detailLabel)
        self.view.addSubview(stackView)
        
        // MARK: - Configuring Layout
        let constraits = [
            informationView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 40),
            informationView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -40),
            informationView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -325),
            informationView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 40),
            
            stackView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -40),
            stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40),
            stackView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 40),
            
            stackView.arrangedSubviews[0].heightAnchor.constraint(equalToConstant: 50),
            stackView.arrangedSubviews[1].heightAnchor.constraint(equalToConstant: 50),
            
            imageView.topAnchor.constraint(equalTo: informationView.topAnchor),
            imageView.rightAnchor.constraint(equalTo: informationView.rightAnchor, constant: -5),
            imageView.bottomAnchor.constraint(equalTo: informationView.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: informationView.leftAnchor, constant: 5),
            
            detailLabel.topAnchor.constraint(equalTo: informationView.bottomAnchor),
            detailLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            detailLabel.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -80),
            detailLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor),
        ]
        
        NSLayoutConstraint.activate(constraits)
        
    }
    
    // MARK: - Actions
    @objc func backButtonPressed(_ sender: UIButton) {
        print("BackButton Pressed")
        let data = imgManager.getImage(next: false)
        for subview in view.subviews {
            if subview.tag == 100 {
                let imageView = subview as! UIImageView
                
                if let image = data.image {
                    UIView.transition(with: imageView, duration: 0.75, options: .transitionCrossDissolve, animations: {
                        imageView.image = image
                        
                    }, completion: nil)
                } else {
                    print("There is No images left")
                }
            } else if subview.tag == 200 {
                let detailLabel = subview as! UILabel
                if let detail = data.detail {
                    UIView.transition(with: detailLabel, duration: 0.75, options: .transitionCrossDissolve, animations: {
                        detailLabel.text = detail
                      }, completion: nil)
                } else {
                    print("There is No detailText left")
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
        let data = imgManager.getImage(next: true)
        for subview in view.subviews {
            if subview.tag == 100 {
                let imageView = subview as! UIImageView
                if let image = data.image {
                    UIView.transition(with: imageView, duration: 0.75, options: .transitionCrossDissolve, animations: {
                        imageView.image = image
                        
                    }, completion: nil)
                } else {
                    print("There No images left")
                }
            } else if subview.tag == 200 {
                let detailLabel = subview as! UILabel
                if let detail = data.detail {
                    UIView.transition(with: detailLabel, duration: 0.75, options: .transitionCrossDissolve, animations: {
                        detailLabel.text = detail
                      }, completion: nil)
                } else {
                    print("There is No detailText left")
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
        questionLabel.font = UIFont(name: "Helvetica", size: 40)
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
        questionLabel.font = UIFont(name: "Helvetica", size: 40)
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
    
    var dataModel = TableDataManger<OccupationItem>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        let gradientBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        gradientBackgroundView.layer.animate(colors: [UIColor.white.cgColor, UIColor.red.cgColor, UIColor.purple.cgColor, UIColor.red.cgColor], duration: 4.0, sizing: self.view.bounds)
        self.tableView = UITableView()
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.backgroundColor = .white
        self.tableView?.register(BlurTableViewCell.self, forCellReuseIdentifier: "occupationCell")
        
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
        questionLabel.font = UIFont(name: "Helvetica", size: 40)
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
        return dataModel.elementsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "occupationCell", for: indexPath) as! BlurTableViewCell
        let emoji: String
        if let user = user {
            emoji = dataModel.elementsList[indexPath.row].elements[0].emoji.getEmojiType(type: user.gender)
        } else {
            emoji = dataModel.elementsList[indexPath.row].elements[0].emoji.getEmojiType(type: .man)
        }
        let title = dataModel.elementsList[indexPath.row].elements[0].title
        cell.set(emoji: emoji, country: title)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let heroCollectionViewController = HeroesCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        Occupation.allCases.forEach {
            if $0.rawValue.lowercased() == dataModel.elementsList[indexPath.row].elements[0].title.lowercased() {
                self.user.occupation = $0
            }
        }
        print(dataModel.elementsList[indexPath.row].elements[0].title.lowercased())
        print(user.occupation)
        let heroDataManager = TableDataManger<HeroItem>(gender: user.gender, occupation: user.occupation, country: user.region.regionName)
        heroCollectionViewController.user = user
        heroCollectionViewController.dataManager = heroDataManager.elementsList
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(heroCollectionViewController, animated: true)
    }
    
    @objc func userSwiped(_ sender: UIGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
}

class HeroesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var dataManager: [HeroItem]!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(HeroCollectionViewCell.self, forCellWithReuseIdentifier: "heroCell")
        
        if self.dataManager.count == 0 {
            let alertNavigateController = UIAlertController(title: "We are still searching for info...", message: "For example, to see found Heroes ⚛︎, \nYou can Swipe Right to move \nto America(USA)-unspecified-inventor ✦", preferredStyle: .actionSheet)
            let alertNavigateAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            })
            alertNavigateController.addAction(alertNavigateAction)
            
            let alertContoller = UIAlertController(title: "No Heroes found in this section 😔", message: "We are still searching.\n You can become first of them 🤠!", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                self.present(alertNavigateController, animated: true, completion: nil)
            })
            

            alertContoller.addAction(alertAction)
            
            present(alertContoller, animated: true, completion: nil)
        }
        
        collectionView.backgroundColor = .clear
        
        let colors = [UIColor.blue.cgColor, UIColor.purple.cgColor, UIColor.white.cgColor, UIColor.black.cgColor]
        let blurView = UIView()
        blurView.frame = self.view.bounds
        blurView.layer.animate(colors: colors, duration: 5.0, sizing: blurView.bounds)
        
        let gestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(userSwiped(_:)))
        self.view.addGestureRecognizer(gestureRecogniser)
        
        self.view.addSubview(blurView)
        self.view.sendSubviewToBack(blurView)
        
//        self.view.layer.animate(colors: [UIColor.yellow.cgColor, UIColor.blue.cgColor, UIColor.green.cgColor, UIColor.purple.cgColor], duration: 2.0, sizing: self.view.bounds)
//        self.view.backgroundColor = .green
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataManager.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "heroCell", for: indexPath) as! HeroCollectionViewCell
        let subCellView = cell.contentView.subviews[0]
        let heroByIndex = dataManager[indexPath.row]

        cell.heroImageView.image = heroByIndex.image.small
        cell.heroNameLabel.text = heroByIndex.name
        cell.heroCountryLabel.text = heroByIndex.elements[0].emoji
        cell.heroQuoteLabel.text = heroByIndex.quotes.first

        
        subCellView.layer.cornerRadius = 10
        subCellView.layer.shadowRadius = 5
        subCellView.layer.shadowOpacity = 1
        subCellView.layer.shadowOffset = .zero
        subCellView.layer.shadowColor = UIColor.white.cgColor
        
        subCellView.clipsToBounds = false
        subCellView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
//        switch heroByIndex.gender {
//        case .man:
//            subCellView.backgroundColor = UIColor(red: 225/255, green: 1, blue: 1, alpha: 0.5)
//        case .woman:
//            subCellView.backgroundColor = UIColor(red: 238/255, green: 130/255, blue: 238/255, alpha: 0.5)
//        default:
//            subCellView.backgroundColor = UIColor(red: 144/255, green: 238/255, blue: 144/255, alpha: 0.5)
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 150, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let descriptionViewController = HeroDescriptionViewController()
        descriptionViewController.image = dataManager[indexPath.item].image.large
        descriptionViewController.name = dataManager[indexPath.item].name
        descriptionViewController.country = dataManager[indexPath.item].elements[0].title + " \(dataManager[indexPath.item].elements[0].emoji)"
        descriptionViewController.information = dataManager[indexPath.item].information
        descriptionViewController.quotes = dataManager[indexPath.item].quotes
        
        print(indexPath.item)
        showDetailViewController(descriptionViewController, sender: nil)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    @objc func userSwiped(_ sender: UIGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
}

class HeroDescriptionViewController: UIViewController {

    var image: UIImage!
    var name: String!
    var country: String!
    var information: String!
    var quotes: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    func updateUI() {
        guard let image = image, let name = name, let country = country, let information = information, let quotes = quotes else {
            fatalError("Some of hero description properties are nil")
        }
        self.view.backgroundColor = .white

        let imageView = UIImageView()
        let nameLabel = UILabel()
        let countryLabel = UILabel()
        let textView = UITextView()
        let quoteStackView = UIStackView()


        // MARK: Turning off AutoResizing
        imageView.translatesAutoresizingMaskIntoConstraints = false
        quoteStackView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        countryLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Configuring UI Elements
        imageView.image = image
        imageView.contentMode = .scaleAspectFit

        nameLabel.text = name
        nameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        countryLabel.text = country
        countryLabel.font = UIFont(name: "HelveticaNeue", size: 16)

        textView.text = information
        textView.isEditable = false
        textView.font = UIFont(name: "HelveticaNeue", size: 14)
        
        quoteStackView.spacing = 3
        quoteStackView.alignment = .trailing
        quoteStackView.distribution = .fillEqually
        quoteStackView.axis = .vertical

        for quote in quotes {
            let quoteLabel = UILabel()
            quoteLabel.textAlignment = .right
            quoteLabel.text = quote
            quoteLabel.font = UIFont(name: "HelveticaNeue-Italic", size: 12)
            quoteLabel.numberOfLines = 3
            quoteLabel.textColor = .gray
            quoteStackView.addArrangedSubview(quoteLabel)
        }

        // MARK: Adding subviews to View
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(countryLabel)
        view.addSubview(textView)
        view.addSubview(quoteStackView)

        // MARK: Configuring Constraits
        let constraits = [
            imageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8),
            imageView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            nameLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            nameLabel.heightAnchor.constraint(equalToConstant: 22),
            
            countryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            countryLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            countryLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            countryLabel.heightAnchor.constraint(equalToConstant: 18),
            
            textView.topAnchor.constraint(equalTo: countryLabel.bottomAnchor, constant: 8),
            textView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            textView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            textView.heightAnchor.constraint(equalToConstant: 200),
            
            quoteStackView.topAnchor.constraint(equalTo: textView.bottomAnchor),
            quoteStackView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            quoteStackView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            quoteStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20),
        ]

        NSLayoutConstraint.activate(constraits)
    }
}

//class HeroDescriptionViewController: UIViewController {
//
//    var image: UIImage!
//    var name: String!
//    var country: String!
//    var information: String!
//    var quotes: [String]!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        updateUI()
//    }
//
//    func updateUI() {
//        let nibFile = UINib(nibName: "DetailView", bundle: .main)
//        let nibView = nibFile.instantiate(withOwner: self, options: .none).first! as? UIView
//
//        for view in nibView!.subviews {
//            if let imageView = view as? UIImageView {
//                imageView.image = self.image
//            } else if let nameLabel = view as? UILabel, nameLabel.tag == 100 {
//                nameLabel.text = name
//            } else if let countryLabel = view as? UILabel, countryLabel.tag == 200 {
//                countryLabel.text = country
//            } else if let infoTextView = view as? UITextView {
//                infoTextView.text = information
//            } else if let quotesStackView = view as? UIStackView {
//                for (index, quote) in quotes.enumerated() {
//                    (quotesStackView.arrangedSubviews[index] as! UILabel).text = quote
//                }
//            }
//        }
//        nibView?.bounds = self.view.frame
//        nibView?.backgroundColor = .black
//        if let nibView = nibView {
//            self.view.addSubview(nibView)
//        }
//
//        let constaints = [
//            nibView!.topAnchor.constraint(equalTo: self.view.topAnchor),
//            nibView!.rightAnchor.constraint(equalTo: self.view.rightAnchor),
//            nibView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//            nibView!.leftAnchor.constraint(equalTo: self.view.leftAnchor),
//        ]
//
//        NSLayoutConstraint.activate(constaints)
//    }
//}

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
        contentView.addSubview(nibView!.subviews.first!)
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
let collectionViewController = HeroesCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
let navigationContoller = UINavigationController(rootViewController: master)
navigationContoller.preferredContentSize = CGSize(width: 350, height: 700)
PlaygroundPage.current.liveView = navigationContoller


final class ImageManager {
    var arrayOfImages = [UIImage]()
    var detailLabels = ["See that everything is possible", "Follow the instruction", "Find your like-minded Heroes"]
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
    
    func getImage(next: Bool) -> (image: UIImage?, detail: String?) {
        if arrayOfImages.count != 0 && next {
            if imageCounter == 0 {
                imageCounter = 1
            }
            let resultImage = arrayOfImages[imageCounter]
            let resultDetail = imageCounter < 3 ? detailLabels[imageCounter] : nil
            if imageCounter + 1 != arrayOfImages.count {
                imageCounter = imageCounter + 1
            }
            print("increase \(imageCounter)")
            return (image: resultImage, detail: resultDetail)
        } else if !next {
            
            if imageCounter - 1 != -1 {
                imageCounter = imageCounter - 1
            }
            let resultImage = arrayOfImages[imageCounter]
            let resultDetail = imageCounter < 3 ? detailLabels[imageCounter] : nil
            print("decrease \(imageCounter)")
            return (image: resultImage, detail: resultDetail)
        }
        return (image: nil, detail: nil)
    }
    
    func getFirstImage() -> (image: UIImage?, detail: String?) {
        if arrayOfImages.count != 0 {
            let resultImage = arrayOfImages[imageCounter]
            let resultDetail = imageCounter < 3 ? detailLabels[imageCounter] : nil
            if imageCounter + 1 != arrayOfImages.count {
                imageCounter = imageCounter + 1
            }
            print("increase \(imageCounter)")
            return (image: resultImage, detail: resultDetail)
        }
        return (image: nil, detail: nil)
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





