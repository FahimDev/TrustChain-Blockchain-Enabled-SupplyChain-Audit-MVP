import type { NextPage } from "next";
import bannerStyles from "../../styles/Banner.module.css";

interface Props{
  title: string;
  subtitle?: string;
}

const BannerComponent: NextPage<Props> = ({title, subtitle}) => {
  return (
    <div className={bannerStyles.main}>
      <header className={bannerStyles.header_banner_top}>
        <div className={bannerStyles.banner}>
          <div className={bannerStyles.banner_image}></div>

          <div className={bannerStyles.primary_wrapper}>
            <h1 className={bannerStyles.site_title}>
              <a href="#">{title}</a>
            </h1>
            <div className={bannerStyles.site_tagline}>
              {subtitle}
            </div>
          </div>
        </div>
      </header>
    </div>
  );
};
export default BannerComponent;
