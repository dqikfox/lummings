import { createFileRoute } from "@tanstack/react-router";
import { Grove } from "@/components/grove";

export const Route = createFileRoute("/")({ component: Home });

function Home() {
  return <Grove />;
}
