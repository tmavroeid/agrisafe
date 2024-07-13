import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import ClickOutside from "@/components/ClickOutside";

import { Connector, useConnect } from 'wagmi'

const DropdownUser = () => {
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const { connectors, connect } = useConnect()

  return (
    <ClickOutside onClick={() => setDropdownOpen(false)} className="relative">
      <Link
        onClick={() => setDropdownOpen(!dropdownOpen)}
        className="flex items-center gap-4"
        href="#"
      >
        <w3m-button />
      </Link>

    </ClickOutside>
  );
};

export default DropdownUser;
