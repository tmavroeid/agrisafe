"use client";
import Link from "next/link";

export default function LinkButton(props: any) {
  const {
    title = "Button",
    target
  } = props

  return (
    <Link
      href={target}
      className="inline-flex items-center justify-center rounded-full bg-primary px-10 py-4 text-center font-medium text-white hover:bg-opacity-90 lg:px-8 xl:px-10 cursor-pointer"
    >
      {title}
    </Link>
  )
}