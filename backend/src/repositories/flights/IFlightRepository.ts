import { Flight } from "../../models/Flight";

export interface IFlightRepository {
    findPassengerCountPerYearPerMonth(): Promise<Flight[]>;
}