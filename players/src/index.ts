import { get_db_pool } from "./db";
import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import { PlayerRepository } from "./repositories/PlayerRepository";

const main = async () => {
    const pool = await get_db_pool();

    const player_repo = new PlayerRepository(pool);

    const app = express();

    app.use(express.json());
    app.use(cors());

    app.get('/', async (req: Request, res: Response) => {
        const players = await player_repo.fetchPlayersData();

        res.status(200).send(players);
    });

    app.get('/health', async (req: Request, res: Response) => {
        res.status(200).send('Ok');
    });

    app.listen(4000, () => {
        console.log('Listening on port 4000');
    });
};

main();