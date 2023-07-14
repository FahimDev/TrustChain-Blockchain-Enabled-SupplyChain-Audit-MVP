import "../styles/navBar.css";
import "../styles/globals.css";
import type { AppProps } from "next/app";
import Head from "next/head";
// Web3
import { Web3ReactProvider } from "@web3-react/core";
import { Web3Provider } from "@ethersproject/providers";
// Icons
import "@fortawesome/fontawesome-svg-core/styles.css";
import { library } from "@fortawesome/fontawesome-svg-core";
import { fas } from "@fortawesome/free-solid-svg-icons";
library.add(fas);
// Component
import NavBar from "../components/layouts/nav-bar"; // https://github.com/gopinav/Next-JS-Tutorials/tree/master/next-misc

const getLibrary = (provider: any) => {
  return new Web3Provider(provider);
};

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <Web3ReactProvider getLibrary={getLibrary}>
      <NavBar />
      <Component {...pageProps} />
    </Web3ReactProvider>
  );
}

export default MyApp;
