import Link from "next/link";

export default function Rounded({title = "Button"}) {
  return (
    <Link
      href="#"
      className="inline-flex items-center justify-center rounded-full bg-primary px-10 py-4 text-center font-medium text-white hover:bg-opacity-90 lg:px-8 xl:px-10"
    >
      {title}
    </Link>
  )
}