import { Flight } from '../models/Flight';
import { Pool } from 'mysql2/promise';
import { IFlightsRepository } from './IFlightsRepository';

export class FlightsRepository implements IFlightsRepository {
    private readonly db: Pool;

    constructor(db: Pool) {
        this.db = db;
    }

    public async findPassengerCountPerYearPerMonth(): Promise<Flight[]> {
        const query = 'SELECT \
            YEAR(departure_date) AS year,\
            MONTHNAME(departure_date) AS month,\
            SUM(passenger_count) AS passengers \
            FROM flight_logs \
            GROUP BY \
            YEAR(departure_date), \
            MONTHNAME(departure_date);';

        const [rows, _] = await this.db.query(query);

        return rows as Flight[];
    }
}