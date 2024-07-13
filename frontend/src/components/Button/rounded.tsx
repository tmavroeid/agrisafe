"use client";

export default function Rounded(props: any) {
  const {
    title = "Button",
    onClick = () => {}
  } = props

  return (
    <button
      onClick={onClick}
      className="inline-flex items-center justify-center rounded-full bg-primary px-10 py-4 text-center font-medium text-white hover:bg-opacity-90 lg:px-8 xl:px-10 cursor-pointer"
    >
      {title}
    </button>
  )
}