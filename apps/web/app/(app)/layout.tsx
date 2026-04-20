import { AuthGate } from "@/components/auth/auth-gate";
import { AppShell } from "@/components/common/app-shell";

export default function AuthenticatedLayout({ children }: { children: React.ReactNode }) {
  return (
    <AuthGate>
      <AppShell>{children}</AppShell>
    </AuthGate>
  );
}

