import { ethers } from "hardhat";
import "dotenv/config";

async function main() {
    const consumerSC = process.env['MUMBAI_CONSUMER_CONTRACT_ADDRESS'] || "";
    const OracleConsumerContract = await ethers.getContractAt("YourContract", consumerSC);

    const [deployer] = await ethers.getSigners();

    console.log('Setting attestor...');
    const attestor = process.env['MUMBAI_PHALA_ORACLE_ATTESTOR'] || deployer.address;
    await OracleConsumerContract.setAttestor(attestor); // change this to the identity of your ActionOffchainRollup found in your Phala Oracle deployment labeled 'Oracle Endpoint'
    console.log(`🚨NOTE🚨\nMake sure to set the Consumer Contract Address in your Phat Contract 2.0 UI dashboard (https://dashboard.phala.network)\n- Go to the 'Configuration' tab and update the 'Client' box\n- Set value to ${consumerSC}`)
    console.log('Done');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
