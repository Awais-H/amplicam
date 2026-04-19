export async function fetchGraphql<T>(query: string, variables?: Record<string, unknown>): Promise<T> {
  const response = await fetch(process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:3000/graphql", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    credentials: "include",
    body: JSON.stringify({ query, variables })
  });

  if (!response.ok) {
    throw new Error(`GraphQL request failed with status ${response.status}`);
  }

  const json = (await response.json()) as { data?: T; errors?: Array<{ message: string }> };
  if (json.errors?.length) {
    throw new Error(json.errors[0]?.message ?? "Unknown GraphQL error");
  }

  return json.data as T;
}

