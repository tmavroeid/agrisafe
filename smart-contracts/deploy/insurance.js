module.exports = async ({deployments}) => {
  const {deploy} = deployments;
  const [deployer] = await ethers.getSigners();

  await deploy('InsuranceData', {
    from: deployer.address,
    args: [
      '0x469449f251692E0779667583026b5A1E99512157',
      'app_staging_82d304654019266eb39a83b29a806fe2',
      'inslogin'
    ],
    log: true,
  });

};
module.exports.tags = ['Insurance'];