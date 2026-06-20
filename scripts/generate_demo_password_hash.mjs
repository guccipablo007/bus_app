import bcrypt from 'bcryptjs';

const password = process.env.DEMO_PASSWORD;

if (!password) {
  console.error('DEMO_PASSWORD is required.');
  process.exit(1);
}

console.log(await bcrypt.hash(password, 10));
