import { hashOTP, compareOTP, generateOTP } from './src/utils/helpers.js';

async function test() {
  const otp = generateOTP();
  const hash = await hashOTP(otp);
  const match = await compareOTP(otp, hash);
  console.log({ otp, hash, match });
  process.exit(0);
}
test();
