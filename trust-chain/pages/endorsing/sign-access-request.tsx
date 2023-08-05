import type { NextPage } from "next";
import Head from "next/head";
import Image from "next/image";
import styles from "../../styles/AccessRequestForm.module.css";
import SignAccessRequestComponent from "../../components/endorse/sign-access-request"; // https://github.com/vercel/next.js/tree/canary/examples
import TabHeaderComponent from "../../components/layouts/tab-header"; 

const SignAccessRequest: NextPage = () => {

  return (
    <div className={styles.container}>
      <TabHeaderComponent title="Pending Sign Request" />
      <SignAccessRequestComponent />
    </div>
  );
};
export default SignAccessRequest;
