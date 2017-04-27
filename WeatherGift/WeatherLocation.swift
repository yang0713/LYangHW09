//
//  WeatherLocation.swift
//  WeatherGift
//
//  Created by Liuke Yang on 3/26/17.
//  Copyright © 2017 Liuke Yang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WeatherLocation: WeatherUserDefault {
    
    struct DailyForecast {
        var dailyMaxTemp: Double
        var dailyMinTemp: Double
        var dailySummary: String
        var dailyDate: Double
        var dailyIcon: String
    }
    
    struct HourlyForecast {
        var hourlyTemp: Double
        var hourlyTime: Double
        var hourlyIcon: String
        var hourlyPrecipProb: Double
    }
    

    var currentTemp = -999.9
    var dailySummary = ""
    var currentIcon = ""
    var currentTime = 0.0
    var timeZone = ""
    var dailyForecastArray = [DailyForecast]()
    var hourlyForecastArray = [HourlyForecast]()
    
    

    
    func getWeather(completed: @escaping () -> ()) {
        
        let weatherURL = urlBase + urlAPIKey + coordinates
        print(weatherURL)
        
        Alamofire.request(weatherURL).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let temperature = json["currently"]["temperature"].double {
                    print("Temp inside getWeather =  \(temperature)")
                    self.currentTemp = temperature
                } else {
                    print("Could not return a temperature!")
                }
                if let summary = json["daily"]["summary"].string {
                    print("SUMMARY inside getWeather =  \(summary)")
                    self.dailySummary = summary
                } else {
                    print("Could not return a summary!")
                }
                if let icon = json["currently"]["icon"].string {
                    print("ICON inside getWeather =  \(icon)")
                    self.currentIcon = icon
                } else {
                    print("Could not return an icon!")
                }
                if let time = json["currently"]["time"].double {
                    print("TIME inside getWeather =  \(time)")
                    self.currentTime = time
                } else {
                    print("Could not return a time!")
                }
                if let timeZone = json["timezone"].string {
                    print("TIMEZONE inside getWeather =  \(timeZone)")
                    self.timeZone = timeZone
                } else {
                    print("Could not return a summary!")
                }
                let dailyDataArray = json["daily"]["data"]
                self.dailyForecastArray = []
                let lastDay = min(dailyDataArray.count-1, 6)
                for day in 1...lastDay {
                    let maxTemp = json["daily"]["data"][day]["temperatureMax"].doubleValue
                    let minTemp = json["daily"]["data"][day]["temperatureMin"].doubleValue
                    let dailySummary = json["daily"]["data"][day]["summary"].string
                    let dateValue = json["daily"]["data"][day]["time"].doubleValue
                    let icon = json["daily"]["data"][day]["icon"].string
                    let iconName = icon?.replacingOccurrences(of: "night", with: "day")
                    self.dailyForecastArray.append(DailyForecast(dailyMaxTemp: maxTemp, dailyMinTemp: minTemp, dailySummary:dailySummary!, dailyDate: dateValue, dailyIcon: icon!))
                }

                let hourlyDataArray = json["hourly"]["data"]
                self.hourlyForecastArray = []
                let lastHour = min(hourlyDataArray.count-1, 24)
                for hour in 1...lastHour {
                    let hourlyTime = json["hourly"]["data"][hour]["time"].doubleValue
                    let hourlyIcon = json["hourly"]["data"][hour]["icon"].stringValue
                    let hourlyTemp = json["hourly"]["data"][hour]["temperature"].doubleValue
                    let hourlyPrecipProb = json["hourly"]["data"][hour]["precipProbability"].doubleValue
                    self.hourlyForecastArray.append(HourlyForecast(hourlyTemp: hourlyTemp, hourlyTime: hourlyTime, hourlyIcon: hourlyIcon, hourlyPrecipProb: hourlyPrecipProb))
                }
                print("!!!! hourlyForecastArray = \(self.hourlyForecastArray)")
                
            case .failure(let error):
                print(error)
            }
            completed()
        }
    }
}
