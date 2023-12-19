import { Jugador } from "../../models/Jugador";

export interface Ijugadores {
    trobadadesJugador(): Promise<Jugador[]>;
}