import { get_db_pool } from "./db";
import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import { FlightsRepository } from "./repositories/FlightsRepository";

const main = async () => {
    const pool = await get_db_pool();

    const flights_repo = new FlightsRepository(pool);

    const app = express();

    app.use(express.json());
    app.use(cors());

    app.get('/', async (req: Request, res: Response) => {
        const players = await flights_repo.findPassengerCountPerYearPerMonth();

        res.send(players);
    });

    app.listen(3000, () => {
        console.log('Listening on port 4000');
    });
};

main();