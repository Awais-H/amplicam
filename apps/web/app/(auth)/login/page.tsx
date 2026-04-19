import Link from "next/link";
import { ArrowRight, LockKeyhole } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export default function LoginPage() {
  return (
    <div className="flex min-h-screen items-center justify-center px-4 py-10">
      <Card className="w-full max-w-lg">
        <CardHeader>
          <div className="mb-4 inline-flex h-12 w-12 items-center justify-center rounded-2xl bg-primary text-primaryForeground">
            <LockKeyhole className="h-6 w-6" />
          </div>
          <CardTitle>OAuth sign-in</CardTitle>
          <CardDescription>
            Rails owns the OIDC session. This page is the frontend handoff point before redirecting to the provider callback flow.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <Button className="w-full justify-between">
            Continue with OAuth provider
            <ArrowRight className="h-4 w-4" />
          </Button>
          <p className="text-sm text-mutedForeground">
            On implementation, this button should redirect to <code>/auth/oidc</code> on the Rails API origin.
          </p>
          <Link href="/receipts" className="text-sm font-medium text-primary">
            Continue in demo mode
          </Link>
        </CardContent>
      </Card>
    </div>
  );
}

