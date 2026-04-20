import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "@/lib/utils";

const badgeVariants = cva(
  "inline-flex items-center rounded-full px-2.5 py-1 text-xs font-medium uppercase tracking-[0.14em]",
  {
    variants: {
      variant: {
        default: "bg-accent text-accentForeground",
        success: "bg-success text-successForeground",
        warning: "bg-warning text-warningForeground",
        outline: "border border-white/55 text-neutral-600 dark:border-white/15 dark:text-neutral-400"
      }
    },
    defaultVariants: {
      variant: "default"
    }
  }
);

export interface BadgeProps extends React.HTMLAttributes<HTMLDivElement>, VariantProps<typeof badgeVariants> {}

export function Badge({ className, variant, ...props }: BadgeProps) {
  return <div className={cn(badgeVariants({ variant }), className)} {...props} />;
}

