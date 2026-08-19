import { apiPath } from "./apiPath";
import { authFetch } from "./authFetch";

export async function loginUser(email: string, password: string) {
  const response = await authFetch(`${apiPath}/auth/loginDashboard`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
  });

  if (!response.ok) {
    throw new Error("Credenciais inválidas");
  }

  return response.json(); 
}

