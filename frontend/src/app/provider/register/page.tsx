"use client";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import { useWriteContract, useAccount } from 'wagmi'
import { abi, address} from '../../../../abis/InsuranceData.json'

export default function RegisterProvider() {
  const account = useAccount()
  const { data: hash, writeContract, isPending } = useWriteContract()

  const register = () => {
    writeContract({
      // @ts-ignore
      address: address,
      abi,
      functionName: 'registerInsuranceProvider',
      args: [account.address],
    })
  }

  return (
    <DefaultLayout>
      <button onClick={register} className="flex w-full justify-center rounded bg-primary p-3 font-medium text-gray hover:bg-opacity-90 loading">
        {isPending ? 'Loading...' : 'Submit'}
      </button>
    </DefaultLayout>
  )
}