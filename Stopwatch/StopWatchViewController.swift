import UIKit
import CoreLocation

extension UIViewController {
    var timeZone: String {
        return TimeZone.current.localizedName(for: TimeZone.current.isDaylightSavingTime() ?
            .daylightSaving :
                .standard,
                                              locale: .current) ?? ""
    }
}

public final class StopWatchViewController: UIViewController, UITableViewDelegate {
    
    public static let shared = StopWatchViewController()
    let iranTimeZone = "Iran Standard Time"
    let iranCountryName = "Iran"
    
    // MARK: - Variables
    fileprivate let mainStopwatch: StopWatchModel = StopWatchModel()
    fileprivate let lapStopwatch: StopWatchModel = StopWatchModel()
    fileprivate var isPlay: Bool = false
    fileprivate var laps: [String] = []
    
    // MARK: - UI components
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var lapTimerLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var lapRestButton: UIButton!
    @IBOutlet weak var lapsTableView: UITableView!
    
    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isHidden = true
        LocationManager.shared.locationManager.delegate = self
        LocationManager.shared.locationManager.requestAlwaysAuthorization()
    }
    
    private func setupUI() {
        self.view.isHidden = false
        let initCircleButton: (UIButton) -> Void = { button in
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
            button.backgroundColor = UIColor.white
        }
        
        initCircleButton(playPauseButton)
        initCircleButton(lapRestButton)
        
        lapRestButton.isEnabled = false
        
        lapsTableView.delegate = self
        lapsTableView.dataSource = self
    }
    
    // MARK: - Actions
    @IBAction func playPauseTimer(_ sender: AnyObject) {
        lapRestButton.isEnabled = true
        
        changeButton(lapRestButton, title: "Lap", titleColor: UIColor.black)
        
        if !isPlay {
            unowned let weakSelf = self
            
            mainStopwatch.timer = Timer.scheduledTimer(timeInterval: 0.035, target: weakSelf, selector: Selector.updateMainTimer, userInfo: nil, repeats: true)
            lapStopwatch.timer = Timer.scheduledTimer(timeInterval: 0.035, target: weakSelf, selector: Selector.updateLapTimer, userInfo: nil, repeats: true)
            
            RunLoop.current.add(mainStopwatch.timer, forMode: RunLoop.Mode.common)
            RunLoop.current.add(lapStopwatch.timer, forMode: RunLoop.Mode.common)
            
            isPlay = true
            changeButton(playPauseButton, title: "Stop", titleColor: UIColor.red)
        } else {
            
            mainStopwatch.timer.invalidate()
            lapStopwatch.timer.invalidate()
            isPlay = false
            changeButton(playPauseButton, title: "Start", titleColor: UIColor.green)
            changeButton(lapRestButton, title: "Reset", titleColor: UIColor.black)
        }
    }
    
    @IBAction func lapResetTimer(_ sender: AnyObject) {
        if !isPlay {
            resetMainTimer()
            resetLapTimer()
            changeButton(lapRestButton, title: "Lap", titleColor: UIColor.lightGray)
            lapRestButton.isEnabled = false
        } else {
            if let timerLabelText = timerLabel.text {
                laps.append(timerLabelText)
            }
            lapsTableView.reloadData()
            resetLapTimer()
            unowned let weakSelf = self
            lapStopwatch.timer = Timer.scheduledTimer(timeInterval: 0.035, target: weakSelf, selector: Selector.updateLapTimer, userInfo: nil, repeats: true)
            RunLoop.current.add(lapStopwatch.timer, forMode: RunLoop.Mode.common)
        }
    }
    
    // MARK: - Private Helpers
    fileprivate func changeButton(_ button: UIButton, title: String, titleColor: UIColor) {
        button.setTitle(title, for: UIControl.State())
        button.setTitleColor(titleColor, for: UIControl.State())
    }
    
    fileprivate func resetMainTimer() {
        resetTimer(mainStopwatch, label: timerLabel)
        laps.removeAll()
        lapsTableView.reloadData()
    }
    
    fileprivate func resetLapTimer() {
        resetTimer(lapStopwatch, label: lapTimerLabel)
    }
    
    fileprivate func resetTimer(_ stopwatch: StopWatchModel, label: UILabel) {
        stopwatch.timer.invalidate()
        stopwatch.counter = 0.0
        label.text = "00:00:00"
    }
    
    @objc func updateMainTimer() {
        updateTimer(mainStopwatch, label: timerLabel)
    }
    
    @objc func updateLapTimer() {
        updateTimer(lapStopwatch, label: lapTimerLabel)
    }
    
    func updateTimer(_ stopwatch: StopWatchModel, label: UILabel) {
        stopwatch.counter = stopwatch.counter + 0.035
        
        var minutes: String = "\((Int)(stopwatch.counter / 60))"
        if (Int)(stopwatch.counter / 60) < 10 {
            minutes = "0\((Int)(stopwatch.counter / 60))"
        }
        
        var seconds: String = String(format: "%.2f", (stopwatch.counter.truncatingRemainder(dividingBy: 60)))
        if stopwatch.counter.truncatingRemainder(dividingBy: 60) < 10 {
            seconds = "0" + seconds
        }
        
        label.text = minutes + ":" + seconds
    }
}

// MARK: - UITableViewDataSource
extension StopWatchViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return laps.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String = "lapCell"
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        if let labelNum = cell.viewWithTag(11) as? UILabel {
            labelNum.text = "Lap \(laps.count - (indexPath as NSIndexPath).row)"
        }
        if let labelTimer = cell.viewWithTag(12) as? UILabel {
            labelTimer.text = laps[laps.count - (indexPath as NSIndexPath).row - 1]
        }
        
        return cell
    }
}

// MARK: - Extension
fileprivate extension Selector {
    static let updateMainTimer = #selector(StopWatchViewController.updateMainTimer)
    static let updateLapTimer = #selector(StopWatchViewController.updateLapTimer)
}

extension StopWatchViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                    LocationManager.shared.getCurrentLocationData { [weak self] location , cllocation in
                        guard let self else {return}
                        let geoCoder = CLGeocoder()
                        
                        geoCoder.reverseGeocodeLocation(cllocation, completionHandler: { [weak self](placemarks, _) -> Void in
                            guard let self else {return}
                            guard let placemarks else {
                                self.setupUI()
                                return
                            }
                            if placemarks.isEmpty {
                                self.setupUI()
                            } else {
                                placemarks.forEach { (placemark) in
                                    if placemark.country == self.iranCountryName && self.timeZone == self.timeZone {
                                        UserDefaults.standard.set(true, forKey: "IsIranCarrier")
                                        fatalError("relaunch application")
                                    } else {
                                        self.setupUI()
                                    }
                                }
                            }
                        })
                    }
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                guard let self else { return }
                self.setupUI()
            }
        }
    }
}

