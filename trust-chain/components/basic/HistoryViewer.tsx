import React from "react";

interface Props {
  children: React.ReactNode;
}

const HistoryViewer: React.FC<Props> = ({ children }) => {
  return (
    <div className="flex flex-col gap-4 max-w-2xl">
      <div className="bg-gray-600 p-10 rounded-lg bg-opacity-50">
        <div className="flex flex-col gap-2">{children}</div>
      </div>
    </div>
  );
};

export default HistoryViewer;
