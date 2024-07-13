import Link from "next/link";
import Image from "next/image";
import { Insurance } from "@/types/insurance";

import RoundedButton from "@/components/Button/rounded"

const defaultData: Insurance[] = [
  {
    name: "Apple Watch Series 7",
    description: "This is the description",
    from: '01/07/2024',
    to: '30/07/2024',
    id: '12345',
    ratioBase: '100',
    ratio: '1',
    liquidityAmount: '200000'
  },
  
];

const Table = props => {
  const {
    productData = defaultData
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

      {productData.map((insurance: Insurance) => (
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
              {insurance.from}
            </p>
          </div>
          <div className="col-span-1 flex items-center">
            <p className="text-sm text-black dark:text-white">
              {insurance.to}
            </p>
          </div>
          <div className="col-span-1 flex items-center">
            <p className="text-sm text-black dark:text-white">
              {insurance.ratio}/{insurance.ratioBase}
            </p>
          </div>
          <div className="col-span-1 flex items-center">
            <p className="text-sm text-black dark:text-white">
              ${insurance.liquidityAmount}
            </p>
          </div>
          <div className="col-span-1 flex items-center">
            <RoundedButton title="Purchase"/>
          </div>
        </div>
      ))}
    </div>
  );
};

export default Table;
