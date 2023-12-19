import { Flight } from "./models/Flight";
import {Jugador} from "./models/Jugador";
import { Ijugadores } from "./repositories/jugadores/Ijugadores";
import { IFlightRepository } from "./repositories/flights/IFlightRepository";

export class Controller {
    private readonly flight_repo: IFlightRepository;
    private readonly jugadores_repo: Ijugadores;

    constructor(jugadores_repo : Ijugadores , flight_repo: IFlightRepository){
        this.flight_repo = flight_repo;
        this.jugadores_repo = jugadores_repo;
    }

    public async get_jugaores(): Promise<Jugador[]> {
        const jugadores = await this.jugadores_repo.trobadadesJugador();

        return jugadores;
    }

    public async get_flights_count_year_month(): Promise<Flight[]> {
        const flights = await this.flight_repo.findPassengerCountPerYearPerMonth();

        return flights;
    }

}