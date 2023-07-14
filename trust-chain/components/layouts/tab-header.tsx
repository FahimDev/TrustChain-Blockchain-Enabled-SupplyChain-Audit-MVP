import type { NextPage } from "next";
import Head from "next/head";
import Image from "next/image";

const TabHeaderComponent: NextPage = ({ title }:any) => {
  return (
    <div>
      <Head>
        <title>{title ? title : 'eSIM Blockchain'}</title>
        <meta
          name="description"
          content="Mobile Network Operator eSIM Management System"
        />
        <link rel="icon" href="Brainstation23.ico" />
      </Head>
    </div>
  );
};
export default TabHeaderComponent;
