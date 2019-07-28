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
    private let cellReuseIdentifier = "cell"
    private lazy var label: UILabel = { l in
        l.textAlignment = .center
        l.text = GetDeviceResolutionKt.getDeviceResolution()
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }(UILabel())

    private lazy var textField: UITextField = { tf in
        tf.text = "CocoaHeads-Khabarovsk"
        tf.backgroundColor = .lightGray
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }(UITextField())

    private lazy var btn1: UIButton = { b in
        b.setTitle("get status", for: .normal)
        b.addTarget(self, action: #selector(getStatus), for: .touchUpInside)
        return b
    }(UIButton(type: .system))

    private lazy var btn2: UIButton = { b in
        b.setTitle("get events", for: .normal)
        b.addTarget(self, action: #selector(getEvents), for: .touchUpInside)
        return b
    }(UIButton(type: .system))

    private lazy var table: UITableView = { t in
        t.translatesAutoresizingMaskIntoConstraints = false
        t.dataSource = self
        t.rowHeight = 12
        return t
    }(UITableView())

    private lazy var stackView: UIStackView = { s in
        s.translatesAutoresizingMaskIntoConstraints = false
        s.spacing = 8
        return s
    }(UIStackView(arrangedSubviews: [btn1, btn2]))

    var log = [String]()

    override func viewDidLoad() {
        NSLog("\(#function) in \(#file)")
        super.viewDidLoad()
        addAllSubviews()
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        api = MeetupApi(delegate: self)
        storage.addLog(message: "viewDidLoad")
        getLogMessages()
    }

    private func addAllSubviews() {
        view.addSubview(label)
        view.addSubview(textField)
        view.addSubview(table)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 20.0),
            textField.widthAnchor.constraint(equalTo: label.widthAnchor),
            textField.centerXAnchor.constraint(equalTo: label.centerXAnchor),
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10.0),

            label.heightAnchor.constraint(equalToConstant: 20.0),
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20.0),
            view.rightAnchor.constraint(equalTo: label.rightAnchor, constant: 20.0),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 30.0),

            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: stackView.centerYAnchor, constant: 80),

            table.leftAnchor.constraint(equalTo: view.leftAnchor),
            table.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            view.rightAnchor.constraint(equalTo: table.rightAnchor),
            view.bottomAnchor.constraint(equalTo: table.bottomAnchor)
            ])
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
        let cell = table.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
        cell.textLabel?.text = log[indexPath.row]
        return cell
    }
}

