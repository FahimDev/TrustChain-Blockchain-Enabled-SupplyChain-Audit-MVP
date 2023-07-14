import type { NextPage } from "next";
import Head from "next/head";
import Image from "next/image";
import styles from "../styles/Home.module.css";
import { useState, useEffect } from "react";
import { ethers } from "ethers";
const ContractAddress = require("../../json-log/deployedContractAddress.json");
import TechCardsComponent from "../components/dashboard/tech-cards";
import BannerComponent from "../components/dashboard/banner";

const Home: NextPage = () => {

  return (
    <div>
      <Head>
        <title>TrustChain: Supply Chain Solution</title>
        <meta name="description" content="A PoC project of Brain Station 23" />
        <link rel="icon" href="/Brainstation23.ico" />
      </Head>
      <BannerComponent />
      <TechCardsComponent />
      <footer className={styles.footer}>
        <a
          href="https://brainstation-23.com/?bc"
          target="_blank"
          rel="noopener noreferrer"
        >
          Powered by{" "}
          <span className={styles.logo}>
            <Image
              src="/bs23.svg"
              alt="Brain Station 23 Logo"
              width={72}
              height={16}
            />
          </span>
        </a>
      </footer>
    </div>
  );
};

export default Home;
