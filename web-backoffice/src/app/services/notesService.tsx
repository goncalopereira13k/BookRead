import { apiPath } from "./apiPath";
import { authFetch } from "./authFetch";


export const fetchNotesToday = async (): Promise<number> => {
    const token = localStorage.getItem("token");
    const today = new Date().toISOString().split("T")[0]; // formato YYYY-MM-DD

    const response = await authFetch(`${apiPath}/books/notes/count?date=${today}`, {
        headers: {
            Authorization: `Bearer ${token}`,
        },
    });

    if (!response.ok) {
        throw new Error("Erro ao buscar número de notas do dia");
    }

    const data = await response.json();

    return data.count;
};

export const fetchNotesLast7Days = async (): Promise<{ date: string, count: number }[]> => {
    const token = localStorage.getItem("token");
    const days: string[] = [];
    const today = new Date();
    for (let i = 6; i >= 0; i--) {
        const d = new Date(today);
        d.setDate(today.getDate() - i);
        const yyyy = d.getFullYear();
        const mm = String(d.getMonth() + 1).padStart(2, '0');
        const dd = String(d.getDate()).padStart(2, '0');
        days.push(`${yyyy}-${mm}-${dd}`);
    }

    // Faz um fetch para cada dia
    const results = await Promise.all(days.map(async (date) => {
        const response = await authFetch(`${apiPath}/books/notes/count?date=${date}`, {
            headers: { Authorization: `Bearer ${token}` },
        });
        if (!response.ok) return { date, count: 0 };
        const data = await response.json();
        return { date, count: data.count ?? 0 };
    }));

    return results;
};


export const fetchNotesLast15Days = async (): Promise<{ date: string, count: number }[]> => {
    const token = localStorage.getItem("token");
    const days: string[] = [];
    const today = new Date();
    for (let i = 14; i >= 0; i--) {
        const d = new Date(today);
        d.setDate(today.getDate() - i);
        const yyyy = d.getFullYear();
        const mm = String(d.getMonth() + 1).padStart(2, '0');
        const dd = String(d.getDate()).padStart(2, '0');
        days.push(`${yyyy}-${mm}-${dd}`);
    }

    // Faz um fetch para cada dia
    const results = await Promise.all(days.map(async (date) => {
        const response = await authFetch(`${apiPath}/books/notes/count?date=${date}`, {
            headers: { Authorization: `Bearer ${token}` },
        });
        if (!response.ok) return { date, count: 0 };
        const data = await response.json();
        return { date, count: data.count ?? 0 };
    }));

    return results;
}


export const fetchNotesLastMonth = async (): Promise<{ date: string, count: number }[]> => {
    const token = localStorage.getItem("token");
    const days: string[] = [];
    const today = new Date();
    for (let i = 29; i >= 0; i--) {
        const d = new Date(today);
        d.setDate(today.getDate() - i);
        const yyyy = d.getFullYear();
        const mm = String(d.getMonth() + 1).padStart(2, '0');
        const dd = String(d.getDate()).padStart(2, '0');
        days.push(`${yyyy}-${mm}-${dd}`);
    }

    // Faz um fetch para cada dia
    const results = await Promise.all(days.map(async (date) => {
        const response = await authFetch(`${apiPath}/books/notes/count?date=${date}`, {
            headers: { Authorization: `Bearer ${token}` },
        });
        if (!response.ok) return { date, count: 0 };
        const data = await response.json();
        return { date, count: data.count ?? 0 };
    }));

    return results;
}