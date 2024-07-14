"use client";
import { useEffect, useState } from "react";
import AvailableInsurancesTableLP from "@/components/Tables/AvailableInsurancesTableLP";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import Breadcrumb from "@/components/Breadcrumbs/Breadcrumb";
import { useReadContract, useReadContracts } from 'wagmi'
import { formatEther } from 'viem'
import { address, abi } from '../../../../../abis/InsuranceData.json';
import { Insurance } from "@/types/insurance";

export default function Browse() {
  const [insurancesToRead, setInsurancesToRead] = useState([])
  const [insurancesParsed, setInsurancesParsed] = useState([])
  const [liquiditiesToRead, setLiquiditiesToRead] = useState([])

  const { data: insurancesNum } = useReadContract({
    // @ts-ignore
    address,
    abi,
    functionName: 'insuranceId',
    args: [],
  })

  // @ts-ignore
  const { data: insurances } = useReadContracts({contracts: insurancesToRead})
  const { data: liquidities } = useReadContracts({contracts: liquiditiesToRead})

  console.log('liquidities:', liquidities)

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
    const reads = []

    if(insurancesNum === 0) return;
  
    // @ts-ignore
    for (let i = 0 ; i < insurancesNum ; i++) {
      reads.push({
        // @ts-ignore
        address,
        abi,
        functionName: 'insuranceliquidity',
        args: [i.toString()],
      })
    }

    // @ts-ignore
    setLiquiditiesToRead(reads)
  }, [insurancesNum])

  useEffect(() => {
    if(!insurances) return
    if(!liquidities) return

    const parsed: Insurance[] = insurances!.map((insurance: any, index: number): Insurance => {
      const startTs = (Number(insurance.result[1].toString()) * 1000)
      const start = new Date(startTs)

      const endTs = (Number(insurance.result[2].toString()) * 1000)
      const end = new Date(endTs)

      // console.log('liquidities:', liquidities[index])

      return {
        id: index.toString(),
        start: start.toDateString(),
        end: end.toDateString(),
        type: insurance.result[3],
        provider: insurance.result[4],
        name: insurance.result[7],
        description: insurance.result[8],
        riskNumerator: insurance.result[9].toString(),
        riskDenominator: insurance.result[10].toString(),
        // @ts-ignore
        liquidityAmount: formatEther(liquidities[index].result),
      }
    })

    // @ts-ignore
    setInsurancesParsed(parsed)
  }, [insurances, liquidities])


  return (
    <DefaultLayout>
      <Breadcrumb pageName="Browse" />

      <div className="flex flex-col gap-10">
        <AvailableInsurancesTableLP data={insurancesParsed}/>
      </div>
    </DefaultLayout>
  )
}