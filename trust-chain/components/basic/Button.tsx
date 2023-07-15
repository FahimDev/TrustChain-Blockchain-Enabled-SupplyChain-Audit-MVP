import React from "react";
import Link from "next/link";

interface Props {
  title: string;
  href: string;
  color: string;
}
const Button: React.FC<Props> = ({ title, href, color }) => {
  return (
    <Link href={href}>
      <a
        className={`bg-${color}-500 text-white active:bg-${color}-600 font-bold uppercase text-sm px-6 py-3 rounded-full shadow hover:shadow-lg outline-none focus:outline-none mr-1 mb-1 ease-linear transition-all duration-150`}
      >
        {title}
      </a>
    </Link>
  );
};

export default Button;
