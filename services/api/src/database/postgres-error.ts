export interface PostgresError extends Error {
  code?: string;
}

export function isPostgresError(error: unknown, code: string): error is PostgresError {
  return error instanceof Error && (error as PostgresError).code === code;
}
