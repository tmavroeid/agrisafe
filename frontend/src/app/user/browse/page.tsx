"use client";
import { useEffect, useState } from "react";
import AvailableInsurances from "@/components/Tables/AvailableInsurancesTable";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import Breadcrumb from "@/components/Breadcrumbs/Breadcrumb";
import { useReadContract, useReadContracts } from 'wagmi'
import { address, abi } from '../../../../abis/InsuranceData.json';
import { Insurance } from "@/types/insurance";

export default function Browse() {
  const [insurancesToRead, setInsurancesToRead] = useState([])
  const [insurancesParsed, setInsurancesParsed] = useState([])
  const [liquiditiesToRead, setLiquiditiesToRead] = useState([])
  const [insuranceLiquidity, setInsuranceLiquidity] = useState([])

  const { data: insurancesNum } = useReadContract({
    // @ts-ignore
    address,
    abi,
    functionName: 'insuranceId',
    args: [],
  })

  // @ts-ignore
  const { data: insurances } = useReadContracts({contracts: insurancesToRead})
  const { data: liquidities } = useReadContracts({contracts: insurancesToRead})

  useEffect(() => {
    const reads = []

    if(insurancesNum === 0) return;
  
    // @ts-ignore
    for (let i = 0 ; i < insurancesNum ; i++) {
      reads.push({
        // @ts-ignore
        address,
        abi,
        functionName: 'insurances',
        args: [i.toString()],
      })
    }

    // @ts-ignore
    setInsurancesToRead(reads)
  }, [insurancesNum])

  useEffect(() => {
    if(!insurances) return

    const parsed: Insurance[] = insurances!.map((insurance: any, index: number): Insurance => {
      const startTs = (Number(insurance.result[1].toString()) * 1000)
      const start = new Date(startTs)

      const endTs = (Number(insurance.result[2].toString()) * 1000)
      const end = new Date(endTs)


      return {
        id: index.toString(),
        start: start.toDateString(),
        end: end.toDateString(),
        type: insurance.result[3],
        provider: insurance.result[4],
        name: insurance.result[5],
        description: insurance.result[6],
        riskNumerator: insurance.result[7].toString(),
        riskDenominator: insurance.result[8].toString(),
        liquidityAmount: '0'
      }
    })

    // @ts-ignore
    setInsurancesParsed(parsed)
  }, [insurances])

  return (
    <DefaultLayout>
      <Breadcrumb pageName="Browse" />

      <div className="flex flex-col gap-10">
        <AvailableInsurances data={insurancesParsed}/>
      </div>
    </DefaultLayout>
  )
}