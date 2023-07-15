import React from "react";

interface Props{
    title: string;
    data: string;
}

const DetailRow: React.FC<Props> = ({title, data}) => {
  return (
    <div className="grid grid-cols-2">
      <div>{title} :</div>
      <p>{data}</p>
    </div>
  );
};

export default DetailRow;
