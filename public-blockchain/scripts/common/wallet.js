const { ethers, providers } = require('ethers')
require('dotenv').config()


const NETWORK = process.env.NETWORK || 'ganache'
const PRIVATE_KEY = `0x${process.env.WALLET_PRIVATE_KEY}` // process.env.PRIVATE_KEY || ''

const URL = () => {
    if (NETWORK === 'ganache') return `${process.env.GANACHE_URL}:${process.env.GANACHE_PORT}`
    if (NETWORK === 'goerli') return `${process.env.GOERLI_ENDPOINT}/${process.env.ALCHEMY_API_KEY}`
    return 'http://localhost:7545'
}

const provider = new providers.JsonRpcProvider(URL())
 
const createWalletFromPK = () => {
    const wallet = new ethers.Wallet(PRIVATE_KEY, provider)
    return wallet
}
 
const getWallet = () => {
    return createWalletFromPK()
}

module.exports = {createWalletFromPK, getWallet}