import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import { Controller } from './controller';

export class Server {
    private app: Application;
    private controller: Controller;
    private port: number;

    constructor(controller: Controller, port: number = 4000) {
        this.app = express();
        this.controller = controller;
        this.port = port;

        this.config();
        this.routes();
    }

    private config() {
        this.app.use(cors());
        this.app.use(express.json());
    }

    private routes() {
        this.app.get('/flights/count', this.get_flight_month.bind(this));
        this.app.get('/jugadores',this.get_jugadores.bind(this));
    }

    private async get_jugadores(req: Request, res: Response) {
        const jugadores = await this.controller.get_jugaores();

        res.send(jugadores);
    }

    private async get_flight_month(req: Request, res: Response) {
        const flights = await this.controller.get_flights_count_year_month();

        res.send(flights); 
    }

    public listen() {
        this.app.listen(this.port, () => {
            console.log(`Listening on port ${this.port}`);
        });
    }
}