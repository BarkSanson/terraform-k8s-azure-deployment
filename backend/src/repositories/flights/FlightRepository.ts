import { Flight } from '../../models/Flight';
import { Pool } from 'mysql2/promise';
import { IFlightRepository } from './IFlightRepository';

export class FlightRepository implements IFlightRepository {
    private readonly db: Pool;

    constructor(db: Pool) {
        this.db = db;
    }

    public async findPassengerCountPerYearPerMonth(): Promise<Flight[]> {
        // Do a sql query to get the month and passengers grouped
        // by month
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

    public async findAll(): Promise<Flight[]> {

        const [rows, _] = await this.db.query('SELECT * FROM flight_logs');

        return rows as Flight[];
    }
}