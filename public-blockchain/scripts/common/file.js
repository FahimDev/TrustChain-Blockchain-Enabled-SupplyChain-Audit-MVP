const fs = require('fs');
const path = require('path');

const SignVerify = require("../../artifacts/contracts/VerifySignData.sol/VerifySignData.json");

const getPricingABI = () => {
    let abiData = JSON.stringify(SignVerify.abi);
    return abiData;
};

module.exports = {getPricingABI}