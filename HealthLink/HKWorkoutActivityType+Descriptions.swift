//
//  HKWorkoutActivityType+Descriptions.swift
//  HealthLink
//
//  Created by Jason Kusnier on 5/25/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import HealthKit

extension HKWorkoutActivityType {
    static func hkDescription(t: HKWorkoutActivityType) -> String {
        switch t {
        case AmericanFootball: return "AmericanFootball"
        case Archery: return "Archery"
        case AustralianFootball: return "AustralianFootball"
        case Badminton: return "Badminton"
        case Baseball: return "Baseball"
        case Basketball: return "Basketball"
        case Bowling: return "Bowling"
        case Boxing: return "Boxing"
        case Climbing: return "Climbing"
        case Cricket: return "Cricket"
        case CrossTraining: return "CrossTraining"
        case Curling: return "Curling"
        case Cycling: return "Cycling"
        case Dance: return "Dance"
        case DanceInspiredTraining: return "DanceInspiredTraining"
        case Elliptical: return "Elliptical"
        case EquestrianSports: return "EquestrianSports"
        case Fencing: return "Fencing"
        case Fishing: return "Fishing"
        case FunctionalStrengthTraining: return "FunctionalStrengthTraining"
        case Golf: return "Golf"
        case Gymnastics: return "Gymnastics"
        case Handball: return "Handball"
        case Hiking: return "Hiking"
        case Hockey: return "Hockey"
        case Hunting: return "Hunting"
        case Lacrosse: return "Lacrosse"
        case MartialArts: return "MartialArts"
        case MindAndBody: return "MindAndBody"
        case MixedMetabolicCardioTraining: return "MixedMetabolicCardioTraining"
        case PaddleSports: return "PaddleSports"
        case Play: return "Play"
        case PreparationAndRecovery: return "PreparationAndRecovery"
        case Racquetball: return "Racquetball"
        case Rowing: return "Rowing"
        case Rugby: return "Rugby"
        case Running: return "Running"
        case Sailing: return "Sailing"
        case SkatingSports: return "SkatingSports"
        case SnowSports: return "SnowSports"
        case Soccer: return "Soccer"
        case Softball: return "Softball"
        case Squash: return "Squash"
        case StairClimbing: return "StairClimbing"
        case SurfingSports: return "SurfingSports"
        case Swimming: return "Swimming"
        case TableTennis: return "TableTennis"
        case Tennis: return "Tennis"
        case TrackAndField: return "TrackAndField"
        case TraditionalStrengthTraining: return "TraditionalStrengthTraining"
        case Volleyball: return "Volleyball"
        case Walking: return "Walking"
        case WaterFitness: return "WaterFitness"
        case WaterPolo: return "WaterPolo"
        case WaterSports: return "WaterSports"
        case Wrestling: return "Wrestling"
        case Yoga: return "Yoga"
        default: return "Other"
        }
    }
}