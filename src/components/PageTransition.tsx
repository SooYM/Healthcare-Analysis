"use client";

import { AnimatePresence, motion, useReducedMotion } from "framer-motion";
import { usePathname } from "next/navigation";
import type { ReactNode } from "react";

export function PageTransition({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const reduceMotion = useReducedMotion();

  if (reduceMotion) {
    return <>{children}</>;
  }

  return (
    <div className="page-transition-root">
      <AnimatePresence mode="wait" initial={false}>
        <motion.div
          key={pathname}
          className="page-transition-surface"
          initial={{ opacity: 0, rotateX: -10, rotateY: 14, y: 12, scale: 0.985 }}
          animate={{ opacity: 1, rotateX: 0, rotateY: 0, y: 0, scale: 1 }}
          exit={{ opacity: 0, rotateX: 8, rotateY: -10, y: -10, scale: 0.99 }}
          transition={{
            duration: 0.55,
            ease: [0.22, 1, 0.36, 1],
          }}
        >
          {children}
        </motion.div>
      </AnimatePresence>
    </div>
  );
}

