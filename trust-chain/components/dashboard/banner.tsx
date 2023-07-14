import type { NextPage } from "next";
import bannerStyles from "../../styles/Banner.module.css";

const BannerComponent: NextPage = () => {
  return (
    <div className={bannerStyles.main}>
      <header className={bannerStyles.header_banner_top}>
        <div className={bannerStyles.banner}>
          <div className={bannerStyles.banner_image}></div>

          <div className={bannerStyles.primary_wrapper}>
            <h1 className={bannerStyles.site_title}>
              <a href="#">Welcome to Trust Chain Dapp</a>
            </h1>
            <div className={bannerStyles.site_tagline}>
            Global Supply Chain DAO and Ownership manaement in {" "}
            <code>Blockchain</code>
            </div>
          </div>
        </div>
      </header>
    </div>
  );
};
export default BannerComponent;
