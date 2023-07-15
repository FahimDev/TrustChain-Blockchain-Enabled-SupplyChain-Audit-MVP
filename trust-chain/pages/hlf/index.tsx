import BannerComponent from "../../components/dashboard/banner";

const index = () => {
  const title = "Hyperledger Fabric Portal";
  const subtitle = "Global Supply Chain Visualizer";
  return (
    <div>
      <BannerComponent title={title} subtitle={subtitle} />
    </div>
  )
}

export default index