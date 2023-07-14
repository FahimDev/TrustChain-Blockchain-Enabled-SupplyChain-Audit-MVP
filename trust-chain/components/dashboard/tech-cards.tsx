import type { NextPage } from "next";
import cardStyles from "../../styles/TechCards.module.css";

// Design Ref: https://codepen.io/mrReiha
const TechCardsComponent: NextPage = () => {
  return (
    <div className={cardStyles.main}>
      <div className="p-20">
        <div className={cardStyles.wrapper}>
          <h2 className="font-mono text-slate-100">
            <strong>Tools and Tech</strong>
          </h2>

          <div className={cardStyles.cards}>
            <figure className={cardStyles.card}>
              <img src="/card_images/ETH.png" />
              <figcaption>Ethereum</figcaption>
            </figure>
            <figure className={cardStyles.card}>
              <img src="/card_images/metamask.jpeg" />
              <figcaption>MetaMask</figcaption>
            </figure>
            <figure className={cardStyles.card}>
              <img src="/card_images/hardhat.jpg" />
              <figcaption>HardHat</figcaption>
            </figure>
            <figure className={cardStyles.card}>
              <img src="/card_images/ganache.png" />
              <figcaption>Ganache</figcaption>
            </figure>
            <figure className={cardStyles.card}>
              <img src="/card_images/nextJs.jpg" />
              <figcaption>Next.js</figcaption>
            </figure>
            <figure className={cardStyles.card}>
              <img src="/card_images/postgresSQL.png" />
              <figcaption>PostgresSQL</figcaption>
            </figure>
            <figure className={cardStyles.card}>
              <img src="/card_images/github.png" />
              <figcaption>GitHub</figcaption>
            </figure>
            <figure className={cardStyles.card}>
              <img src="/card_images/openSea.png" />
              <figcaption>OpenSea</figcaption>
            </figure>
          </div>

          <h2 className="font-mono text-slate-100">
            <strong>What's new?</strong>
          </h2>

          <div className={cardStyles.news}>
            <figure className={cardStyles.article}>
              <img src="https://global-uploads.webflow.com/5fad86e2327507cecea2d5e8/618c085946474a1d23b8f10a_Will%20MetaMask%20Launch%20a%20_MASK%20Token-p-1080.jpg" />

              <figcaption>
                <h3>Update</h3>

                <p>
                  While the MetaMask wallet is great for those who are
                  comfortable around cryptocurrency, it isn't the best option
                  for those very new in the space. Because the wallet is
                  susceptible to malware and social engineering attacks, those
                  who don't understand what red flags to watch for are at a high
                  risk of losing their assets.
                </p>
              </figcaption>
            </figure>
          </div>
        </div>
      </div>
    </div>
  );
};
export default TechCardsComponent;
