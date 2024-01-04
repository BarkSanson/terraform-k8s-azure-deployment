import mysql2, { PoolOptions, Pool } from 'mysql2/promise';
import * as fs from 'fs/promises';

export async function get_db_pool(): Promise<Pool> {
    const secrets_dir = process.env["SECRETS_DIR"];

    const user_path = `${secrets_dir}/ASI-DB-USER`;
    const password_path = `${secrets_dir}/ASI-DB-PASS`;

    const user = await fs.readFile(user_path, 'utf-8');
    const password = await fs.readFile(password_path, 'utf-8');

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