import { Player } from "../models/Player";

export interface IPlayerRepository {
    fetchPlayersData(): Promise<Player[]>;
}