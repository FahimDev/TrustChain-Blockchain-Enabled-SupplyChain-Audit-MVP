import React from "react";
import Button from "./Button";
import { useRouter } from "next/router";

interface Props {
  children: React.ReactNode;
  icon?: string;
  title: string;
  created?: string;
}

const DetailViewer: React.FC<Props> = ({ children, icon, title }) => {
  const router = useRouter();

  return (
    <div className="flex flex-col gap-4 max-w-2xl">
      <div className="relative">
        <div className="bg-gray-600 p-10 rounded-lg bg-opacity-50">
          <div className="flex flex-col items-center gap-3">
            <div className="w-16 h-16">
              <img className="rounded-full" src={icon} alt={`${title} Icon`} />
            </div>
            <div className="text-2xl">{title}</div>
          </div>
        </div>

        <div className="absolute top-8 right-4">
          <Button
            title="History"
            color="cyan"
            href={`${router.asPath}/history`}
          />
        </div>
      </div>

      <div className="bg-gray-600 p-10 rounded-lg bg-opacity-50">
        <div className="flex flex-col gap-2">{children}</div>
      </div>
    </div>
  );
};

export default DetailViewer;
