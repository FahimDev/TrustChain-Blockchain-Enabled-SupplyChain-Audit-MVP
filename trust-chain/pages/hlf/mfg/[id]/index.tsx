import { useRouter } from "next/router";
import { NextPage } from "next";

import BannerComponent from "../../../../components/dashboard/banner";
import DetailViewer from "../../../../components/basic/DetailViewer";
import DetailRow from "../../../../components/basic/DetailRow";

const MFGDetail: NextPage = () => {
  const router = useRouter();
  const id = router.query.id;
  const detail = {
    logo: "https://fastly.picsum.photos/id/446/200/200.jpg?hmac=PkaLcCtgL4IvAz-gsxbCXz_tl0qdVUGOrxhYLrywa-c",
    title: "Toyota",
    created: "22/04/2012",
  };
  return (
    <div className="h-screen flex flex-col">
      <BannerComponent title={`Manufacturer Detail of ID: ${id}`} />
      <div className="container mx-auto flex-1 flex flex-col justify-center items-center ">
        <DetailViewer icon={detail.logo} title={detail.title}>
          <DetailRow title="MFG ID" data="1" />
          <DetailRow title="Tin Num" data="171963" />
          <DetailRow
            title="Description"
            data="Toyota Motor Corporation is a Japanese multinational automotive manufacturer headquartered in Toyota City, Aichi, Japan."
          />
        </DetailViewer>
      </div>
    </div>
  );
};

export default MFGDetail;
