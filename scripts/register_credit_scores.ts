/**
 * PRIVATE_KEY={private_key} ts-node scripts/register_credit_scores.ts "{network}"
 */
import { ethers, providers } from 'ethers'

import {
  TrueFiCreditOracle__factory,
} from '../build'

// inputs
const oracleAddressMainnet = '0x73581551665680696946f568259977Da02e8712A'
const txnArgs = { gasLimit: 1_000_000, gasPrice: 60_000_000_000 }

// testnet
let oracleAddress = '0x9ff6ca759631E658444Ba85409a283f55C49bb93'

async function registerCreditScores () {
  const network = process.argv[2]
  const provider = new providers.InfuraProvider(network, 'e33335b99d78415b82f8b9bc5fdc44c0')
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider)

  if (network === 'mainnet') {
    oracleAddress = oracleAddressMainnet
  }

  const oracle = await TrueFiCreditOracle__factory.connect(oracleAddress, wallet)
  const scores = getScores()

  for (let i = 0; i < scores.length; i++) {
    await setScore(oracle, scores[i].score, scores[i].address)
  }
  console.log('\nDONE.')
}

async function setScore (oracle, score, address) {
  if ((await oracle.getScore(address)).toString() !== score.toString()) {
    await (await oracle.setScore(address, score, txnArgs)).wait()
    console.log(`SET:   ${address}: ${score}`)
  } else {
    console.log(`CHECK: ${address}: ${score}`)
  }
}

function getScores () {
  return [
    { score:  95,  address: '0x186cf5714316F47BC59e30a850615A3f938d7D79' },
    { score:  191, address: '0x2ae5C897107AcC1d98a4e245D93A20A8b5a83428' },
    { score:  191, address: '0x6aD71B4DD5BAE567bCF3376fDc48AC5843E19203' },
    { score:  223, address: '0x964d9D1A532B5a5DaeacBAc71d46320DE313AE9C' },
    { score:  191, address: '0xBc8e650Bac6A7590F19A958e0F57ac97261677f0' },
    { score:  159, address: '0xCAFD96A3475aa9afcC66bc5f9FF589C74ce6A4Bc' },
    { score:  191, address: '0xD5DeE8195AE62bC011A89f1959A7A375cc0DaF38' },
    { score:  223, address: '0xdcf45Ec32B553C8274596CD6401dD78A0fAc8CC1' },
    { score:  223, address: '0xEF82e7E85061bd800c040D87D159F769a6b85264' },
    { score:  127, address: '0xf3537ac805e1ce18AA9F61A4b1DCD04F10a007E9' },
  ]
}

registerCreditScores().catch(console.error)
