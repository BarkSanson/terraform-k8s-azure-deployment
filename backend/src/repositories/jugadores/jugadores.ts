import { Jugador } from '../../models/Jugador';
import { Pool } from 'mysql2/promise';
import { Ijugadores } from './Ijugadores';

export class jugadores implements Ijugadores {
    private readonly db: Pool;

    constructor(db: Pool) {
        this.db = db;
    }

    public async trobadadesJugador(): Promise<Jugador[]> {
        const query = 'SELECT nacionalidad, COUNT(CASE WHEN overall BETWEEN 70 AND 79 THEN 1 END) as d8, \
        COUNT(CASE WHEN overall BETWEEN 80 AND 89 THEN 1 END) as d9, COUNT(CASE WHEN overall BETWEEN 90 AND 99 THEN 1 END) as d10, COUNT(nom) as c FROM jugador \
        GROUP BY nacionalidad  ORDER BY c DESC LIMIT 10;';

        const [rows, _] = await this.db.query(query);

        return rows as Jugador[];        
    }

    public async findAll(): Promise<Jugador[]> {

        const [rows, _] = await this.db.query('SELECT * FROM jugador');

        return rows as Jugador[];
    }
}