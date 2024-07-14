const { expect } = require("chai");

describe("InsuranceData", function () {
  it("test 1", async function () {
    const [owner, user, provider, lp1] = await ethers.getSigners();

    const contractInst = await ethers.deployContract("InsuranceData", [
      '0x469449f251692E0779667583026b5A1E99512157',
      'app_staging_82d304654019266eb39a83b29a806fe2',
      'inslogin'
    ]);

    await contractInst.connect(provider).registerInsuranceProvider(provider.address)
    await contractInst.connect(provider).registerInsurance(
      'name',
      1719877511,
      1720223111,
      1,
      '0000',
      '1111',
      'desc',
      1,
      2,
      {value: ethers.utils.parseEther('80')}
    )

    await contractInst.connect(lp1).fundInsurance(0, {value: ethers.utils.parseEther('20')})

    await contractInst.connect(user).buy(
      0,
      {value: ethers.utils.parseEther('50')}
    )
  });
});