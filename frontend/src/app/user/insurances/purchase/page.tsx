"use client";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import Breadcrumb from "@/components/Breadcrumbs/Breadcrumb";
import SelectGroupOne from "@/components/SelectGroup/SelectGroupOne";
import DatePickerOne from "@/components/FormElements/DatePicker/DatePickerOne";

export default function PurchaseInsurance() {
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
            <form action="#">
              <div className="p-6.5">
                <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                  <div className="w-full xl:w-1/2">
                    <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                      Purchase Amount
                    </label>
                    <input
                      type="text"
                      placeholder="100$"
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
                      1/100
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
                      01/07/2024 - 31/07/2024
                    </label>
                  </div>
                </div>
                
                <div className="mb-6 flex gap-6 flex-row">
                  <div className="w-1/2">
                    <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                      Insurance amount
                    </label>
                  </div>
                  <div className="w-1/2 flex flex-row justify-end">
                    <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                      100000$
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
                      100$
                    </label>
                  </div>
                </div>

                <label className="mb-3 block text-sm font-medium text-black dark:text-white">
                  Validity period
                </label>
                <div className="mb-4.5 flex flex-col gap-6 xl:flex-row">
                  <DatePickerOne title="Start"/>
                  <DatePickerOne title="End"/>
                </div>

                <button className="flex w-full justify-center rounded bg-primary p-3 font-medium text-gray hover:bg-opacity-90">
                  Submit
                </button>
              </div>
            </form>
          </div>
        </div>

      </div>
    </DefaultLayout>
  )
}