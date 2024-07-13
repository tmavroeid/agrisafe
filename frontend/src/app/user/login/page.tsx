"use client"
import { IDKitWidget, VerificationLevel } from '@worldcoin/idkit'
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import Button from "@/components/Button/rounded"
import useBearStore from "@/app/state";
import { useAccount } from 'wagmi'


export default function Login() {
  const setWorldIdProof = useBearStore((state: any) => state.setWorldIdProof);
  const account = useAccount()

  const onSuccess = (proof: any) => {
    console.log('on success:', proof)

    setWorldIdProof(proof)
  };

  return (
    <DefaultLayout>
      {/* We dont need backend verification because it will eventually be handled on-chain before purchasing the insurance */}
      <IDKitWidget
        app_id="app_staging_82d304654019266eb39a83b29a806fe2"
        action="inslogin"
        // On-chain only accepts Orb verifications
        verification_level={VerificationLevel.Orb}
        onSuccess={onSuccess}
        // address here 
        signal={account.address}
      >
        {({ open }) => (
          <Button
            onClick={open}
            title="Verify with World ID"
          />
        )}
    </IDKitWidget>
  </DefaultLayout>
  )
}