"use client";
import { SyntheticEvent, useState } from 'react'
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import Breadcrumb from "@/components/Breadcrumbs/Breadcrumb";
import InsuranceTypeSelect from "@/components/InsuranceComponents/InsuranceTypeSelect";
import DatePickerOne from "@/components/FormElements/DatePicker/DatePickerOne";
import { useWriteContract, useAccount } from 'wagmi'
import { parseEther } from 'viem'
import { abi, address} from '../../../../abis/InsuranceData.json'

export default function CreateInsurance() {
  const [insuranceType, setInsuranceType] = useState('')
  const [funding, setFunding] = useState('')
  const [riskLevel, setRiskLEvel] = useState('')
  const [start, setStart] = useState('')
  const [end, setEnd] = useState('')
  const [desc, setDesc] = useState('')
  const [lat, setLat] = useState('')
  const [lon, setLon] = useState('')
  const [name, setName] = useState('')
  const { data: hash, writeContract, isPending, ...rest } = useWriteContract()

  console.log('rest:', rest)

  const onSubmit = () => {
    const startTs = Math.round((new Date(start)).getTime() / 1000)
    const endTs = Math.round((new Date(end)).getTime() / 1000)
    const riskNumerator = riskLevel.split('/')[0]
    const riskDenominator = riskLevel.split('/')[1]

    writeContract({
      // @ts-ignore
      address: address,
      abi,
      functionName: 'registerInsurance',
      value: parseEther(funding),
      args: [
        name,
        startTs.toString(),
        endTs.toString(),
        insuranceType,
        lat,
        lon,
        desc,
        riskNumerator,
        riskDenominator
      ],
    })
  }

  const onChangeInput = (setter: any) => (e: any) => {
    setter(e.target.value)
  }

  const onChangeSelect = (value: string) => {
    setInsuranceType(value)
  }

  return (
    <DefaultLayout>
      <Breadcrumb pageName="Create Insurance" />

      <div className="grid grid-cols-1 gap-9 sm:grid-cols-2">
      <div className="flex flex-col gap-9">
        <div className="rounded-sm border border-stroke bg-white shadow-default dark:border-strokedark dark:bg-boxdark">
          <div className="border-b border-stroke px-6.5 py-4 dark:border-strokedark">
            <h3 className="font-medium text-black dark:text-white">
              Create Insurance Form
            </h3>
          </div>
            <div className="p-6.5">
              <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                <div className="w-full xl:w-1/2">
                  <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                    Name
                  </label>
                  <input
                    onChange={onChangeInput(setName)}
                    type="text"
                    placeholder="My insurance"
                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                  />
                </div>
              </div>

              <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                <div className="w-full xl:w-1/2">
                  <InsuranceTypeSelect onChange={onChangeSelect}/>
                </div>
              </div>

              <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                <div className="w-full xl:w-1/2">
                  <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                    Latitude
                  </label>
                  <input
                    onChange={onChangeInput(setLat)}
                    type="text"
                    placeholder="38.8951"
                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                  />
                </div>
              </div>

              <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                <div className="w-full xl:w-1/2">
                  <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                    Longitude
                  </label>
                  <input
                    onChange={onChangeInput(setLon)}
                    type="text"
                    placeholder="-77.0364 "
                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                  />
                </div>
              </div>

              <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                <div className="w-full xl:w-1/2">
                  <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                    Initial funding amount
                  </label>
                  <input
                    onChange={onChangeInput(setFunding)}
                    type="text"
                    placeholder="10000"
                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                  />
                </div>
              </div>

              <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                <div className="w-full xl:w-1/2">
                  <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                    Risk level
                  </label>
                  <input
                    onChange={onChangeInput(setRiskLEvel)}
                    type="text"
                    placeholder="1/100"
                    className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                  />
                </div>
              </div>

              <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                Validity period
              </label>
              <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                <DatePickerOne title="Start" onChange={setStart}/>
                <DatePickerOne title="End" onChange={setEnd}/>
              </div>

              <div className="mb-6">
                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                  Description
                </label>
                <textarea
                    onChange={onChangeInput(setDesc)}
                    rows={6}
                  placeholder="Type your message"
                  className="w-full rounded border-[1.5px] border-stroke bg-transparent px-5 py-3 text-black outline-none transition focus:border-primary active:border-primary disabled:cursor-default disabled:bg-whiter dark:border-form-strokedark dark:bg-form-input dark:text-white dark:focus:border-primary"
                ></textarea>
              </div>

              <button onClick={onSubmit} className="flex w-full justify-center rounded bg-primary p-3 font-medium text-gray hover:bg-opacity-90">
                {isPending ? 'Loading' : 'Submit'}
              </button>
            </div>
          </div>
        </div>

      </div>
    </DefaultLayout>
  )
}