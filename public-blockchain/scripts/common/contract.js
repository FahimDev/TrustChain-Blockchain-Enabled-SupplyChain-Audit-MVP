const { ethers } = require('ethers');
const { getPricingABI } = require('./file');

const getInstance = (
    address,
    wallet
  ) => {
    const abi = getPricingABI()
    const contract = new ethers.Contract(address, abi, wallet)
    return contract
}

module.exports = {getInstance};