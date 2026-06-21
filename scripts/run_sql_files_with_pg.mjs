import { readFile, readdir, stat } from 'node:fs/promises';
import path from 'node:path';
import process from 'node:process';
import pg from 'pg';

import { normalizePgConnectionString } from './normalize_pg_connection.mjs';

const { Client } = pg;
const databaseUrl = process.env.DATABASE_URL;
const requestedDirectory = process.argv[2] ?? 'database/seeds';
const sqlPath = path.resolve(process.cwd(), requestedDirectory);

if (!databaseUrl) {
  console.error('DATABASE_URL is required in the process environment.');
  process.exit(1);
}

const requestedStat = await stat(sqlPath);
const sqlDirectory = requestedStat.isDirectory() ? sqlPath : path.dirname(sqlPath);
const fileNames = requestedStat.isDirectory()
  ? (await readdir(sqlDirectory))
      .filter((fileName) => /^\d{3}_.+\.sql$/i.test(fileName))
      .sort((left, right) => left.localeCompare(right))
  : [path.basename(sqlPath)].filter((fileName) => /^\d{3}_.+\.sql$/i.test(fileName));

if (fileNames.length === 0) {
  console.error(`No ordered SQL files found in ${requestedDirectory}.`);
  process.exit(1);
}

let client;

async function connectWithRetry() {
  let lastError;
  for (let attempt = 1; attempt <= 3; attempt += 1) {
    const candidate = new Client({
      connectionString: normalizePgConnectionString(databaseUrl),
      connectionTimeoutMillis: 15000,
    });
    try {
      await candidate.connect();
      return candidate;
    } catch (error) {
      lastError = error;
      await candidate.end().catch(() => undefined);
      if (attempt < 3) await new Promise((resolve) => setTimeout(resolve, attempt * 2000));
    }
  }
  throw lastError;
}

try {
  console.log(`Connecting to run ${fileNames.length} ordered SQL files.`);
  client = await connectWithRetry();

  for (const fileName of fileNames) {
    console.log(`Running ${fileName}`);
    const sql = await readFile(path.join(sqlDirectory, fileName), 'utf8');
    await client.query(sql);
  }

  console.log('All SQL files completed successfully.');
} catch (error) {
  console.error('SQL execution stopped on the first error.');
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
} finally {
  await client?.end().catch(() => undefined);
}
