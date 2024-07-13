"use client";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import Breadcrumb from "@/components/Breadcrumbs/Breadcrumb";
import DatePickerOne from "@/components/FormElements/DatePicker/DatePickerOne";
import { formatEther, parseEther } from 'viem'
import { useReadContracts, useWriteContract } from 'wagmi'
import { abi, address } from '../../../../../../abis/InsuranceData.json'
import { useEffect, useState } from "react";
import { Insurance } from "@/types/insurance";

export default function PurchaseInsurance(props: any) {
  const {
    params: {
      insuranceId
    }
  } = props;

  const [insurance, setInsurance] = useState<Insurance>()
  const [insuredAmount, setInsuredMAmount] = useState('0')
  const [userPayAmount, setUserPayAmount] = useState('0')
  const { data: hash, writeContract, isPending, ...rest } = useWriteContract()

  console.log('rest:', rest)

  const {data: insuranceData} = useReadContracts({
    contracts: [
      {
        // @ts-ignore
        address,
        abi,
        functionName: 'insurances',
        args: [insuranceId],
      },
      {
        // @ts-ignore
        address,
        abi,
        functionName: 'insuranceliquidity',
        args: [insuranceId],
      }
    ]
  })

  useEffect(() => {
    if(!insuranceData || !insuranceData[0] || !insuranceData[1]) return;

    // @ts-ignore
    const startTs = (Number(insuranceData[0].result[1].toString()) * 1000)
    const start = new Date(startTs)

    // @ts-ignore
    const endTs = (Number(insuranceData[0].result[2].toString()) * 1000)
    const end = new Date(endTs)


    const tmpInsurance = {
      id: insuranceId,
      start: start.toDateString(),
      end: end.toDateString(),
      // @ts-ignore
      type: insuranceData[0].result[3],
      // @ts-ignore
      provider: insuranceData[0].result[4],
      // @ts-ignore
      name: insuranceData[0].result[5],
      // @ts-ignore
      description: insuranceData[0].result[6],
      // @ts-ignore
      riskNumerator: insuranceData[0].result[7].toString(),
      // @ts-ignore
      riskDenominator: insuranceData[0].result[8].toString(),
      // @ts-ignore
      liquidityAmount: formatEther(insuranceData[1].result),
    }

    setInsurance(tmpInsurance)
  }, [insuranceData, insuranceId])

  useEffect(() => {

  }, [])

  const onChange = (e: any) => {
    const userAmount = parseEther(e.target.value);
    const riskDenominator = parseEther(insurance!.riskDenominator) 
    const riskNumerator = parseEther(insurance!.riskNumerator) 
    const instCost = (userAmount * riskDenominator) / riskNumerator

    setInsuredMAmount(formatEther(instCost).toString())
    setUserPayAmount(e.target.value)
  }

  const onSubmit = () => {
    writeContract({
      // @ts-ignore
      address: address,
      abi,
      functionName: 'buy',
      value: parseEther(userPayAmount),
      args: [insuranceId],
    })
  }

  
  return (
    <DefaultLayout>
      <Breadcrumb pageName="Purchase Insurance" />

      <div className="grid grid-cols-1 gap-9 sm:grid-cols-2">
      <div className="flex flex-col gap-9">
        <div className="rounded-sm border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
          <div className="border-b border-stroke px-6.5 py-4 dark:border-strokedark">
            <h3 className="font-medium text-black dark:text-white">
              Purchase Insurance Form
            </h3>
          </div>
            <div className="p-6.5">
              <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                <div className="w-full xl:w-1/2">
                  <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                    Purchase Amount
                  </label>
                  <input
                    onChange={onChange}
                    type="text"
                    placeholder="100 ETH"
                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                  />
                </div>
              </div>

              <div className="flex gap-6 flex-row">
                <div className="w-1/2">
                  <label className="mb-1 block text-sm font-medium text-black dark:text-white">
                    Risk level
                  </label>
                </div>
                <div className="w-1/2 flex flex-row justify-end">
                  <label className="mb-1 block text-sm font-medium text-black dark:text-white">
                    {insurance?.riskNumerator}/{insurance?.riskDenominator}
                  </label>
                </div>
              </div>

              <div className="flex gap-6 flex-row">
                <div className="w-1/2">
                  <label className="mb-1 block text-sm font-medium text-black dark:text-white">
                    Insured amount
                  </label>
                </div>
                <div className="w-1/2 flex flex-row justify-end">
                  <label className="mb-1 block text-sm font-medium text-black dark:text-white">
                    
                  </label>
                </div>
              </div>

              <div className="flex gap-6 flex-row">
                <div className="w-1/2">
                  <label className="mb-1 block text-sm font-medium text-black dark:text-white">
                    Validity period
                  </label>
                </div>
                <div className="w-1/2 flex flex-row justify-end">
                  <label className="mb-1 block text-sm font-medium text-black dark:text-white">
                    {insurance?.start} - {insurance?.end}
                  </label>
                </div>
              </div>

              <div className="flex gap-6 flex-row">
                <div className="w-1/2">
                  <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                    Insured amount
                  </label>
                </div>
                <div className="w-1/2 flex flex-row justify-end">
                  <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                    {insuredAmount} ETH
                  </label>
                </div>
              </div>
              
              <div className="mb-6 flex gap-6 flex-row">
                <div className="w-1/2">
                  <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                    Max insured amount
                  </label>
                </div>
                <div className="w-1/2 flex flex-row justify-end">
                  <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                    {insurance?.liquidityAmount} ETH
                  </label>
                </div>
              </div>

              <div className="mb-6 flex gap-6 flex-row">
                <div className="w-1/2">
                  <label className="mb-3 block text-md font-medium text-black dark:text-white">
                    Total cost
                  </label>
                </div>
                <div className="w-1/2 flex flex-row justify-end">
                  <label className="mb-3 block text-md font-medium text-black dark:text-white">
                    {userPayAmount} ETH
                  </label>
                </div>
              </div>

              <button onClick={onSubmit} className="flex w-full justify-center rounded bg-primary p-3 font-medium text-gray hover:bg-opacity-90">
                {isPending ? 'Loading...' : 'Submit'}
              </button>
            </div>
          </div>
        </div>

      </div>
    </DefaultLayout>
  )
}