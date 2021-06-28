import { forkChain } from './suite'
import { expect, use } from 'chai'
import { solidity } from 'ethereum-waffle'
import { setupDeploy } from 'scripts/utils'

import {
  OwnedUpgradeabilityProxy,
  OwnedUpgradeabilityProxy__factory,
  TrueFiVault,
  TrueFiVault__factory,
} from 'contracts'

use(solidity)

const BLOCKTOWER_PROXY = '0xB6AE2726B4EF922b723D5F9Fd45bad7b6f3902b4'
const ALAMEDA_IMPL = '0xf053E3e417B7c9abD13aE278E28A1Ef371E8906B'
const OWNER = '0x16cEa306506c387713C70b9C1205fd5aC997E78E'

describe('TrueFiVault', () => {
  let provider
  let owner
  let deployContract

  beforeEach(async () => {
    provider = forkChain('https://eth-mainnet.alchemyapi.io/v2/Vc3xNXIWdxEbDOToa69DhWeyhgFVBDWl', [OWNER])
    owner = provider.getSigner(OWNER)
    deployContract = setupDeploy(owner)
  })

  it('test get storage', async () => {
    for (let i = 0; i < 10; i++) {
      const storage = await provider.getStorageAt(BLOCKTOWER_PROXY, i)
      console.log(`${i}: ${storage}`)
    }
    for (let i = 50; i < 60; i++) {
      const storage = await provider.getStorageAt(BLOCKTOWER_PROXY, i)
      console.log(`${i}: ${storage}`)
    }
    const trueFiVault = TrueFiVault__factory.connect(BLOCKTOWER_PROXY, owner)
    console.log(`isInitialized(): ${await trueFiVault.isInitialized()}`)
    console.log(`owner(): ${await trueFiVault.owner()}`)
    console.log(`beneficiary(): ${await trueFiVault.beneficiary()}`)
    console.log(`expiry(): ${await trueFiVault.expiry()}`)
    console.log(`withdrawn(): ${await trueFiVault.withdrawn()}`)
    console.log(`tru(): ${await trueFiVault.tru()}`)
    console.log(`stkTru(): ${await trueFiVault.stkTru()}`)
  })

  it('test upgrade to alameda impl', async () => {
  	const trueFiVault_proxy = OwnedUpgradeabilityProxy__factory.connect(BLOCKTOWER_PROXY, owner)
  	await trueFiVault_proxy.upgradeTo(ALAMEDA_IMPL)
  	const trueFiVault = TrueFiVault__factory.connect(BLOCKTOWER_PROXY, owner)
    console.log(`isInitialized(): ${await trueFiVault.isInitialized()}`)
    console.log(`owner(): ${await trueFiVault.owner()}`)
    console.log(`beneficiary(): ${await trueFiVault.beneficiary()}`)
    console.log(`expiry(): ${await trueFiVault.expiry()}`)
    console.log(`withdrawn(): ${await trueFiVault.withdrawn()}`)
    console.log(`tru(): ${await trueFiVault.tru()}`)
    console.log(`stkTru(): ${await trueFiVault.stkTru()}`)
  })
})
