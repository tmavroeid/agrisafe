import AvailableInsurances from "@/components/Tables/AvailableInsurancesTable";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import Breadcrumb from "@/components/Breadcrumbs/Breadcrumb";


export default function Browse() {
  return (
    <DefaultLayout>
      <Breadcrumb pageName="Browse" />

      <div className="flex flex-col gap-10">
        <AvailableInsurances />
      </div>
    </DefaultLayout>
  )
}