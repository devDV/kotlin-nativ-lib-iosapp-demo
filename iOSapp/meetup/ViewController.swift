//
//  ViewController.swift
//  meetup
//
//  Created by dattk on 24/07/2019.
//  Copyright © 2019 dattk. All rights reserved.
//

import UIKit
import mplib

class ViewController: UIViewController {
    
    var api: MeetupApi!
    let storage = Storage()
    
    let label = UILabel()
    let textField = UITextField()
    let btn1 = UIButton(type: .system)
    let btn2 = UIButton(type: .system)
    let table = UITableView()

    
    var log = [String]()
    
    override func viewDidLoad() {
        NSLog("\(#function) in \(#file)")
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        api = MeetupApi(delegate: self)
        
        storage.addLog(message: "viewDidLoad")
        
        label.textAlignment = .center
        label.text = GetDeviceResolutionKt.getDeviceResolution()
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        label.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        label.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20.0).isActive = true
        label.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20.0).isActive = true
        label.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30.0).isActive = true
        
        textField.text = "CocoaHeads-Khabarovsk"
        textField.backgroundColor = .lightGray
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(textField)
        textField.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        textField.widthAnchor.constraint(equalTo: label.widthAnchor).isActive = true
        textField.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10.0).isActive = true

//        btn1.tintColor = .red
        btn1.setTitle("get status", for: .normal)
        btn1.addTarget(self, action: #selector(getStatus), for: .touchUpInside)
        self.view.addSubview(btn1)
        
//        btn2.tintColor = .orange
        btn2.setTitle("get events", for: .normal)
        btn2.addTarget(self, action: #selector(getEvents), for: .touchUpInside)
        self.view.addSubview(btn2)
        
//        let btn3 = UIButton(frame: CGRect(x: center.x-50, y: center.y - 40, width: 100, height: 30))
//        btn3.backgroundColor = .green
//        btn3.setTitle("get LOG", for: .normal)
//        btn3.addTarget(self, action: #selector(getLogMessages), for: .touchUpInside)
//        self.view.addSubview(btn3)
        
        table.dataSource = self
        table.rowHeight = 12
        self.view.addSubview(table)
        
        getLogMessages()
    }
    
    override func viewWillLayoutSubviews() {
        NSLog(#function)

        let center = self.view.center
        
        //label (frame: CGRect(x: center.x-100, y: center.y - 150, width: 200, height: 30))
        btn1.frame = CGRect(x: center.x-50-60, y: center.y - 80, width: 100, height: 30)
        btn2.frame = CGRect(x: center.x-50+60, y: center.y - 80, width: 100, height: 30)

        table.frame = CGRect(x: 0, y: center.y - 50, width: center.x*2, height: center.y+50)
    }
    
    @objc func getStatus() {
        NSLog(#function)

        api.getStatus() { status in
            let statusDescription = "status \(status)"
            self.storage.addLog(message: statusDescription)
            //self.getLogMessages()
        }
    }

    @objc func getEvents() {
        NSLog(#function)

        // УБРАЛ ПРОВЕРКУ чтобы в котлин уходила пустая группа
//        guard let groupName = textField.text, !groupName.isEmpty else {
//            return
//        }

        api.getEvents(groupName: textField.text!) { events in
            
            events.forEach({ (event) in
                let eventDescription = "Event \(event.id), \(event.local_date) \(event.local_time) – \(event.name)"
                print(eventDescription)
                self.storage.addLog(message: eventDescription)
            })
            
            //self.getLogMessages()
        }
    }
    
    @objc func getLogMessages() {
        NSLog(#function)
        let numberRow = api.logRows
        let data = storage.getLogLastRows(number: numberRow)
        reloadLogFromData(data: data)
    }
    
}

extension ViewController: MeetupApiDelegate {

    func reloadLogFromData(data: [Log]) {
        NSLog(#function)
        
        log.removeAll()
        guard (data.count > 0) else { return }
        
        //        for row in data {
        //            let date = Date(timeIntervalSince1970: TimeInterval(row.timestamp/1000))
        //            let logString = "\(date) : \(row.description)"
        //            log.append(logString)
        //        }
        
        let format = DateFormatter()
        // http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
        format.dateFormat = "H:mm:ss"
        
        log = data.map { (row) -> String in
            let date = Date(timeIntervalSince1970: TimeInterval(row.timestamp/1000))
            return "\(format.string(from: date)) > \(row.description)"
        }
        table.reloadData()
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return log.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = table.dequeueReusableCell(withIdentifier: "cell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            let newFont = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
            cell?.textLabel?.font = newFont
        }
        
        cell?.textLabel?.text = log[indexPath.row]
        
        return cell!
    
    }
    
}

