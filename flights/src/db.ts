import mysql2, { PoolOptions, Pool } from 'mysql2/promise';


export async function get_db_pool(): Promise<Pool> {
    const user = process.env["ASI-DB-USER"];
    const password = process.env["ASI-DB-PASSWORD"];

    const database = process.env["DB_NAME"];
    const host = process.env["DB_HOST"];
    const portString = process.env["DB_PORT"];

    if (!user || !password || !database || !host || !portString) 
        throw new Error("[ERROR] Could not obtain database credentials. Check your Key Vault configuration and .env file.");

    const port: number = parseInt(portString);

    const access: PoolOptions = {
        user,
        password,
        database,
        host,
        port
    };
    const pool = mysql2.createPool(access);

    return pool;
}