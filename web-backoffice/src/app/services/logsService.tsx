import { apiPath } from "./apiPath";
import { authFetch } from "./authFetch";

// Busca os últimos logs
export const fetchRecentLogs = async (): Promise<any[]> => {
  const token = localStorage.getItem("token");

  const response = await authFetch(`${apiPath}/logs/get10`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    throw new Error("Erro ao buscar os últimos logs");
  }

  const logs = await response.json();
  return logs.slice(0,5); 
};
