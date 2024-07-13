import Link from "next/link";
import Image from "next/image";
import { UserInsurance } from "@/types/user-insurance";

import RoundedButton from "@/components/Button/rounded"

const defaultData: UserInsurance[] = [
  {
    image: "/images/product/product-01.png",
    name: "Apple Watch Series 7",
    status: "Active",
    from: '01/07/2024',
    to: '30/07/2024',
    id: '12345',
    cost: '100$',
    amount: '20000$'
  },
  {
    image: "/images/product/product-02.png",
    name: "Macbook Pro M1",
    status: "Active",
    from: '01/07/2024',
    to: '30/07/2024',
    id: '123456',
    cost: '100$',
    amount: '20000$'
  }
];

const TableTwo = props => {
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
          <p className="font-medium">Status</p>
        </div>
        <div className="col-span-1 flex items-center">
          <p className="font-medium">From</p>
        </div>
        <div className="col-span-1 flex items-center">
          <p className="font-medium">To</p>
        </div>
        <div className="col-span-1 flex items-center">
          <p className="font-medium">Cost</p>
        </div>
        <div className="col-span-1 flex items-center">
          <p className="font-medium">Amount</p>
        </div>
        <div className="col-span-1 flex items-center">
          <p className="font-medium">Actions</p>
        </div>

      </div>

      {productData.map((insurance: UserInsurance) => (
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
              {insurance.status}
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
              ${insurance.amount}
            </p>
          </div>
          <div className="col-span-1 flex items-center">
            <p className="text-sm text-black dark:text-white">{insurance.cost}</p>
          </div>
          <div className="col-span-1 flex items-center">
            <RoundedButton title="Claim"/>
          </div>
        </div>
      ))}
    </div>
  );
};

export default TableTwo;
