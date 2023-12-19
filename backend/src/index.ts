import { Server } from './server';
import { Controller } from './controller';
import { FlightRepository } from './repositories/flights/FlightRepository';
import {jugadores } from './repositories/jugadores/jugadores';
import { get_db_pool } from './db/db'; 

const pool = get_db_pool();

const flight_repo = new FlightRepository(pool);
const jugadores_repo = new jugadores(pool);

const controller = new Controller(jugadores_repo,flight_repo);

const server = new Server(controller);
server.listen();