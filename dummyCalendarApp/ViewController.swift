//
//  ViewController.swift
//  dummyCalendarApp

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var dict = NSMutableDictionary()
    var weekDiet = NSMutableDictionary()
    var dietData = NSMutableArray()
    var timeArr : [String] = ["2018-09-07 19:54:00","2018-09-06 19:55:00"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.getSampleData() //Sample data URL for testing purpose.
        self.getJsonFromUrl() //Server URL.
    }
    
    func getJsonFromUrl(){
        let session = URLSession.shared
        let url = URL(string: "https://naviadoctors.com/dummy/")!
        let task = session.dataTask(with: url) { (data, _, _) -> Void in
            if let data = data {
                let response = try? JSONSerialization.jsonObject(with: data, options: [])
                self.weekDiet = (((response as! NSDictionary).object(forKey: "week_diet_data") as! NSDictionary).mutableCopy() as! NSMutableDictionary)
                self.assignReminder()
            }
        }
        task.resume()
    }
    
    func assignReminder(){
        
        var today = Date()
        
        for _ in 1...7{
            
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)
            let date = DateFormatter()
            date.locale = Locale(identifier: "en_US")
            date.timeZone = TimeZone.current
            date.dateFormat = "yyyy-MM-dd"
            let stringDate : String = date.string(from: today)
            let weekDayName = (self.getDayNameBy(stringDate: stringDate)).lowercased()
            
            if let x = (self.weekDiet).object(forKey: weekDayName){
                
                for i in 0..<(x as! NSArray).count{
                    let temp = NSMutableDictionary()
                    let food = (((x as! NSArray).object(at: i) as! NSDictionary).object(forKey: "food")!)
                    let mealDateTime = "\(stringDate) \((((x as! NSArray).object(at: i) as! NSDictionary).object(forKey: "meal_time"))!):00"
                    
                    temp.setObject(food, forKey: "food" as NSCopying)
                    temp.setObject(mealDateTime, forKey: "meal_time" as NSCopying)
                    self.dietData.add(temp)
                }
            }
            today = tomorrow!
        }
        self.toScheduleNotification()
    }
    
    func toScheduleNotification(){
        for i in 0..<self.dietData.count{
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "UTC")
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
            
            let meal_time = dateFormatter.date(from: ((self.dietData.object(at: i) as! NSDictionary).object(forKey: "meal_time") as! String))
            let food = (self.dietData.object(at: i) as! NSDictionary).object(forKey: "food") as! String
            let reminderTime = Calendar.current.date(byAdding: .minute, value: -5, to: meal_time!)
            let delegate = UIApplication.shared.delegate as? AppDelegate
            
            delegate?.scheduleNotification(at: reminderTime! , count: "\(i)", food: food)
        }
        self.tableView.reloadData()
    }
    
//    @IBAction func datePickerDateChanged(_ sender: UIDatePicker) {
//
//        let selectedDate = sender.date
//        for i in 0..<timeArr.count{
//            let dateFormatter = DateFormatter()
//            dateFormatter.locale = Locale(identifier: "en_US")
//            dateFormatter.timeZone = TimeZone.current
//            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
//
//            let dateString = dateFormatter.string(from: selectedDate)
//            debugPrint("===date \(dateString)")
//            let date = dateFormatter.date(from: timeArr[i])
//            debugPrint("===Selected date \(date)")
//            let delegate = UIApplication.shared.delegate as? AppDelegate
//            delegate?.scheduleNotification(at: date! , count: "\(i)", food: "self.foodName")
//        }
//
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //This function is for test purpose.
    func getSampleData(){
        let jsonString = "{\"diet_duration\": 20, \"week_diet_data\": {\"saturday\": [{\"food\": \"scramblled eggs\", \"meal_time\": \"16:10\"}, {\"food\": \"Burrito bowls\", \"meal_time\": \"16:20\"}, {\"food\": \"Evening snacks\", \"meal_time\": \"16:30\"}, {\"food\": \"North Indian thali\", \"meal_time\": \"16:40\"}], \"wednesday\": [{\"food\": \"Sprouts\", \"meal_time\": \"07:00\"}, {\"food\": \"Bread lintils and Rice\", \"meal_time\": \"16:00\"}, {\"food\": \"Soup ,Rice and Chicken\", \"meal_time\": \"21:00\"}], \"monday\": [{\"food\": \"Warm honey and water\", \"meal_time\": \"07:00\"}, {\"food\": \"proper thali\", \"meal_time\": \"15:00\"}]}}"
    
        let jsonData = jsonString.data(using: .utf8)
        let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
        self.weekDiet = (((dictionary as! NSDictionary).object(forKey: "week_diet_data") as! NSDictionary).mutableCopy() as! NSMutableDictionary)
        
        self.assignReminder()
    }
    
    //MARK: -----------TableView Delegate & Data Source Methods---------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dietData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        
        cell = tableView.dequeueReusableCell(withIdentifier: "foodItemCell")

        let results = self.dietData.object(at: indexPath.row) as! NSDictionary

        let foodNameLabel = cell.viewWithTag(1) as! UILabel
        let mealTimeLbl = cell.viewWithTag(2) as! UILabel
        
        let mealDateTimeString = self.getDateStringFromDateString(date: "\(results.object(forKey: "meal_time")!)", fromDateString: "yyyy-MM-dd HH:mm:SS", toDateString: "dd MMM, yyyy hh:mm a")
        
        foodNameLabel.text = "\((results.object(forKey: "food") as! String).uppercased())"

        mealTimeLbl.text = "\(mealDateTimeString)"
        
        cell.selectionStyle = .none
        return cell
    }
    
    //MARK: -----------Date Formatter Methods---------
    
    func getCurrentdate()->String{
        let today = Date()
        let date = DateFormatter()
        date.locale = Locale(identifier: "en_US")
        date.timeZone = TimeZone.current
        date.dateFormat = "yyyy-MM-dd HH:mm:SS"
        let stringDate : String = date.string(from: today)
        return stringDate
    }
    
    func getDateStringFromDateString(date: String, fromDateString: String, toDateString: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromDateString
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
        let getDate = dateFormatter.date(from: date)
        dateFormatter.dateFormat = toDateString
        return dateFormatter.string(from: getDate!)
    }
    
    func getDateStringFromDate(date: Date, toDateString: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
        dateFormatter.dateFormat = toDateString
        return dateFormatter.string(from: date)
    }
    
    func getDayNameBy(stringDate: String) -> String
    {
        let df  = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        let date = df.date(from: stringDate)!
        df.dateFormat = "EEEE"
        return df.string(from: date);
    }

    
    // MARK: - For Color code
    func colorWithHexString (_ hex:String) -> UIColor
    {
        var cString:String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
}