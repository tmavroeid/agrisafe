import TableTwo from "@/components/Tables/UserInsurancesTable";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import Breadcrumb from "@/components/Breadcrumbs/Breadcrumb";


export default function Browse() {
  return (
    <DefaultLayout>
      <Breadcrumb pageName="Insurances" />

      <div className="flex flex-col gap-10">
        <TableTwo />
      </div>
    </DefaultLayout>
  )
}