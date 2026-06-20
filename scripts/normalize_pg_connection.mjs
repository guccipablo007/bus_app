export function normalizePgConnectionString(connectionString) {
  const url = new URL(connectionString);
  const sslMode = url.searchParams.get('sslmode');

  if (!sslMode) {
    url.searchParams.set('sslmode', 'verify-full');
  } else if (sslMode === 'require') {
    url.searchParams.set('uselibpqcompat', 'true');
  }

  return url.toString();
}
