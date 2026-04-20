import { getAccessToken } from "@/lib/auth/token-storage";

export async function fetchGraphql<T>(query: string, variables?: Record<string, unknown>): Promise<T> {
  const token = getAccessToken();
  const headers: Record<string, string> = {
    "Content-Type": "application/json"
  };
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const response = await fetch("/graphql", {
    method: "POST",
    headers,
    credentials: "include",
    body: JSON.stringify({ query, variables })
  });

  const json = (await response.json()) as {
    data?: T;
    errors?: Array<{ message: string }>;
    error?: string;
  };

  if (!response.ok) {
    const detail = json.errors?.[0]?.message ?? json.error;
    throw new Error(detail ?? `GraphQL request failed with status ${response.status}`);
  }
  if (json.errors?.length) {
    throw new Error(json.errors[0]?.message ?? "Unknown GraphQL error");
  }

  return json.data as T;
}

