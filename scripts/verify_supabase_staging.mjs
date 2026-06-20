import process from 'node:process';
import pg from 'pg';

import { normalizePgConnectionString } from './normalize_pg_connection.mjs';

const { Client } = pg;
const databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
  console.error('DATABASE_URL is required in the process environment.');
  process.exit(1);
}

const expected = {
  roles: 7,
  regions: 5,
  cities: 8,
  agencies: 1,
  terminals: 5,
  buses: 3,
  bus_seats: 150,
  routes: 14,
  residential_areas: 35,
  users: 7,
};

const client = new Client({
  connectionString: normalizePgConnectionString(databaseUrl),
  connectionTimeoutMillis: 15000,
});

try {
  await client.connect();
  const extensionResult = await client.query(
    "SELECT extname FROM pg_extension WHERE extname IN ('postgis', 'pgcrypto') ORDER BY extname",
  );
  const counts = {};
  let passed = true;

  for (const [table, minimum] of Object.entries(expected)) {
    const result = await client.query(`SELECT count(*)::integer AS count FROM ${table}`);
    const count = result.rows[0].count;
    counts[table] = count;
    if (count < minimum) passed = false;
  }

  const extensions = extensionResult.rows.map((row) => row.extname);
  if (!extensions.includes('postgis') || !extensions.includes('pgcrypto')) passed = false;

  console.log(JSON.stringify({ status: passed ? 'passed' : 'failed', extensions, counts }));
  if (!passed) process.exitCode = 1;
} catch (error) {
  console.error('Supabase staging verification failed.');
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
} finally {
  await client.end().catch(() => undefined);
}
