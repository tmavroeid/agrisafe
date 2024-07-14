"use client";
import { Insurance } from "@/types/insurance";

import LinkButton from "@/components/Button/linkButton"

const Table = (props: any) => {
  const {
    data = []
  } = props;

  return (
    <div className="rounded-sm border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
      <div className="px-4 py-6 md:px-6 xl:px-7.5">
        <h4 className="text-xl font-semibold text-black dark:text-white">
          Insurances
        </h4>
      </div>

      <div className="grid grid-cols-6 border-t border-stroke px-4 py-4.5 dark:border-strokedark sm:grid-cols-8 md:px-6 2xl:px-7.5">
        <div className="col-span-1 flex items-center">
          <p className="font-medium">Product Name</p>
        </div>
        <div className="col-span-1 flex items-center">
          <p className="font-medium">From</p>
        </div>
        <div className="col-span-1 flex items-center">
          <p className="font-medium">To</p>
        </div>
        <div className="col-span-1 flex items-center">
          <p className="font-medium">Payout ratio</p>
        </div>
        <div className="col-span-1 flex items-center">
          <p className="font-medium">Liquidity</p>
        </div>
        <div className="col-span-1 flex items-center">
          <p className="font-medium">Actions</p>
        </div>

      </div>

      {data.map((insurance: Insurance) => (
        <div
          className="grid grid-cols-6 border-t border-stroke px-4 py-4.5 dark:border-strokedark sm:grid-cols-8 md:px-6 2xl:px-7.5"
          key={insurance.id}
        >
          <div className="col-span-1 flex items-center">
            <p className="text-sm text-black dark:text-white">
              {insurance.name}
            </p>
          </div>
          <div className="col-span-1 flex items-center">
            <p className="text-sm text-black dark:text-white">
              {insurance.start}
            </p>
          </div>
          <div className="col-span-1 flex items-center">
            <p className="text-sm text-black dark:text-white">
              {insurance.end}
            </p>
          </div>
          <div className="col-span-1 flex items-center">
            <p className="text-sm text-black dark:text-white">
              {insurance.riskNumerator}/{insurance.riskDenominator}
            </p>
          </div>
          <div className="col-span-1 flex items-center">
            <p className="text-sm text-black dark:text-white">
              {insurance.liquidityAmount} ETH
            </p>
          </div>
          <div className="col-span-1 flex items-center">
            <LinkButton title="Fund" target={`/lp/insurances/${insurance.id}/fund`}/>
          </div>
        </div>
      ))}
    </div>
  );
};

export default Table;
