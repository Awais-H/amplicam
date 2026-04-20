import { parseJwtPayload } from "@/lib/auth/jwt-claims";

export const AUTH_STORAGE_KEY = "bookkeeper_auth";

export type StoredAuth = {
  accessToken: string;
  expiresAt: number;
};

function isJwtExpired(accessToken: string): boolean {
  const payload = parseJwtPayload(accessToken);
  if (!payload?.exp) return false;
  return Date.now() / 1000 >= payload.exp;
}

export function getStoredAuth(): StoredAuth | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = localStorage.getItem(AUTH_STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as StoredAuth;
    if (!parsed?.accessToken || !parsed?.expiresAt) return null;
    const now = Date.now() / 1000;
    if (now > parsed.expiresAt || isJwtExpired(parsed.accessToken)) {
      clearStoredAuth();
      return null;
    }
    return parsed;
  } catch {
    return null;
  }
}

export function getAccessToken(): string | null {
  return getStoredAuth()?.accessToken ?? null;
}

export function setStoredAuth(accessToken: string, expiresInSeconds: number): void {
  const expiresAt = Math.floor(Date.now() / 1000) + expiresInSeconds;
  const payload: StoredAuth = { accessToken, expiresAt };
  localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(payload));
}

export function clearStoredAuth(): void {
  localStorage.removeItem(AUTH_STORAGE_KEY);
}
