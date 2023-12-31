import { Player } from '../models/Player';
import { Pool } from 'mysql2/promise';
import { IPlayerRepository } from './IPlayerRepository';

export class PlayerRepository implements IPlayerRepository {
    private readonly db: Pool;

    constructor(db: Pool) {
        this.db = db;
    }

    public async fetchPlayersData(): Promise<Player[]> {
        const query = 'SELECT nationality, COUNT(CASE WHEN overall BETWEEN 70 AND 79 THEN 1 END) as d8, \
        COUNT(CASE WHEN overall BETWEEN 80 AND 89 THEN 1 END) as d9, COUNT(CASE WHEN overall BETWEEN 90 AND 99 THEN 1 END) as d10, COUNT(player_name) as c FROM players\
        GROUP BY nationality ORDER BY c DESC LIMIT 10;';

        const [rows, _] = await this.db.query(query);

        return rows as Player[];        
    }
}