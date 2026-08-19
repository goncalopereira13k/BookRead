import { apiPath } from "./apiPath";
import { authFetch } from "./authFetch";


export const fetchAllUsers = async (): Promise<any[]> => {
  const token = localStorage.getItem("token");

  const response = await authFetch(`${apiPath}/user/all`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    throw new Error("Erro ao buscar utilizadores");
  }

  const users = await response.json();
  return users;
};

export const fetchUserCount = async (): Promise<number> => {
  const token = localStorage.getItem("token");

  const response = await authFetch(`${apiPath}/user/all`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    throw new Error("Erro ao buscar número de utilizadores");
  }

  const users = await response.json();
  return users.length;
};

export const fetchUserById = async (userId: string): Promise<any> => {
  const token = localStorage.getItem("token");

  const response = await authFetch(`${apiPath}/user/${userId}`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    throw new Error("Erro ao buscar utilizador");
  }

  const user = await response.json();
  return user;
};


export const fetchUserCountLast7Days = async (): Promise<{ date: string; count: number }[]> => {
  const allUsers = await fetchAllUsers();

  const last7Days = Array.from({ length: 7 }, (_, i) => {
    const date = new Date();
    date.setDate(date.getDate() - i);
    return date.toISOString().slice(0, 10); // "YYYY-MM-DD"
  }).reverse();

  const counts = last7Days.map(date => {
    const count = allUsers.filter(user =>
      user.createdAt && user.createdAt.startsWith(date)
    ).length;
    return { date, count };
  });

  return counts;
};


export const fetchUserCountLast15Days = async (): Promise<{ date: string; count: number }[]> => {
  const allUsers = await fetchAllUsers();

  const last15Days = Array.from({ length: 15 }, (_, i) => {
    const date = new Date();
    date.setDate(date.getDate() - i);
    return date.toISOString().slice(0, 10); // "YYYY-MM-DD"
  }).reverse();

  const counts = last15Days.map(date => {
    const count = allUsers.filter(user =>
      user.createdAt && user.createdAt.startsWith(date)
    ).length;
    return { date, count };
  });

  return counts;
}

export const fetchUserCountLastMonth = async (): Promise<{ date: string; count: number }[]> => {
  const allUsers = await fetchAllUsers();

  const lastMonth = Array.from({ length: 30 }, (_, i) => {
    const date = new Date();
    date.setDate(date.getDate() - i);
    return date.toISOString().slice(0, 10); // "YYYY-MM-DD"
  }).reverse();

  const counts = lastMonth.map(date => {
    const count = allUsers.filter(user =>
      user.createdAt && user.createdAt.startsWith(date)
    ).length;
    return { date, count };
  });

  return counts;
}


export const fetchUser = async (): Promise<any> => {
  const token = localStorage.getItem("token");

  const response = await authFetch(`${apiPath}/user`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    throw new Error("Erro ao buscar utilizador");
  }

  const data = await response.json();
  return data.user;
};


export const updateUser = async (userId: string, userData: any): Promise<any> => {
  const token = localStorage.getItem("token");

  const response = await authFetch(`${apiPath}/user`, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(userData),
  });

  if (!response.ok) {
    throw new Error("Erro ao atualizar utilizador");
  }

  const updatedUser = await response.json();
  return updatedUser;
};


export const updateUserById = async (userId: string, userData: any): Promise<any> => {
  const token = localStorage.getItem("token");

  
  const response = await authFetch(`${apiPath}/user/updateById`, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      id: userId,
      ...userData}),
  });

  if (!response.ok) {
    throw new Error("Erro ao atualizar utilizador");
  }

  const updatedUser = await response.json();
  return updatedUser;
}

export const deleteUserById = async (userId: string): Promise<void> => {
  const token = localStorage.getItem("token");
  const userIdNumber = parseInt(userId, 10);

  const response = await authFetch(`${apiPath}/user/deleteById`, {
    method: "DELETE",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({ id: userIdNumber }), 
  });

  if (!response.ok) {
    const errorData = await response.json();
    throw new Error("Erro ao eliminar utilizador");
  }
}
