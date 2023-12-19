const { KeyClient } = require("@azure/keyvault-keys");
const { DefaultAzureCredential } = require("@azure/identity");

import mysql2, { PoolOptions, Pool } from 'mysql2/promise';


export async function get_db_pool(): Promise<Pool> {
    const credential = new DefaultAzureCredential();    

    const keyVaultName = process.env["KEY_VAULT_NAME"];
    const KVUri = "https://" + keyVaultName + ".vault.azure.net";

    const client = new KeyClient(KVUri, credential);

    const user = await client.getKey("ASI-DB-USER");
    const password = await client.getKey("ASI-DB-PASSWORD");

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