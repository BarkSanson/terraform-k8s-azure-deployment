import { get_db_pool } from "./db";
import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import { FlightsRepository } from "./repositories/FlightsRepository";

const SERVICE_NAME = 'flights';

const main = async () => {
    const pool = await get_db_pool();

    const flights_repo = new FlightsRepository(pool);

    const app = express();

    app.use(express.json());
    app.use(cors());

    app.get(`/${SERVICE_NAME}`, async (req: Request, res: Response) => {
        res.status(200).send('Ok');
    });

    app.get(`/${SERVICE_NAME}/count`, async (req: Request, res: Response) => {
        const flights_count = await flights_repo.findPassengerCountPerYearPerMonth();

        res.send(flights_count);
    });

    app.get(`/health`, async (req: Request, res: Response) => {
        res.status(200).send('Ok');
    });

    app.listen(3000, () => {
        console.log('Listening on port 3000');
    });
};

main();