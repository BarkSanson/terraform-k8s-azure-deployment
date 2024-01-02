import { Flight } from "../models/Flight";

export interface IFlightsRepository {
    findPassengerCountPerYearPerMonth(): Promise<Flight[]>;
}