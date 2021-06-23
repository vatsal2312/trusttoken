/**
 * PRIVATE_KEY={private_key} ts-node scripts/deploy_usdt_oracle.ts "{network}"
 */

import { ethers, providers } from 'ethers'

import {
  ChainlinkTruUsdtOracle__factory,
  ChainlinkTruUsdtOracle,
} from '../build'

async function deployOracle () {
  const txnArgs = { gasLimit: 5_000_000, gasPrice: 18_000_000_000 }
  const provider = new providers.InfuraProvider(process.argv[2], 'e33335b99d78415b82f8b9bc5fdc44c0')
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider)

  const oracle = await (await new ChainlinkTruUsdtOracle__factory(wallet).deploy(txnArgs)).deployed()
  console.log(`oracle at: ${oracle.address}`)
}

deployOracle().catch(console.error)