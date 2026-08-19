import { apiPath } from "./apiPath";
import { authFetch } from "./authFetch";


export const fetchReadingsToday = async (): Promise<any> => {
    const token = localStorage.getItem("token");

    const today = new Date().toISOString().split("T")[0]; // formato YYYY-MM-DD

    const response = await authFetch(`${apiPath}/readinglog/countPages?date=${today}`, {
        headers: {
            Authorization: `Bearer ${token}`,
        },
    });

    if (!response.ok) {
        throw new Error("Erro ao buscar leituras do dia");
    }

    const readings = await response.json();
    return readings;
};

export const fetchReadingsTodayCount = async (): Promise<any> => {
    const token = localStorage.getItem("token");

    const todayObj = new Date();
    const today = todayObj.getFullYear() + '-' +
        String(todayObj.getMonth() + 1).padStart(2, '0') + '-' +
        String(todayObj.getDate()).padStart(2, '0');
    
    const response = await authFetch(`${apiPath}/readinglog/countPages?date=${today}`, {
        headers: {
            Authorization: `Bearer ${token}`,
        },
    });

    if (!response.ok) {
        throw new Error("Erro ao buscar leituras do dia");
    }


    const readings = await response.json();
    return readings.count;
}

export const fetchReadingsLast7Days = async (): Promise<{ date: string, count: number }[]> => {
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
        const response = await authFetch(`${apiPath}/readinglog/countPages?date=${date}`, {
            headers: { Authorization: `Bearer ${token}` },
        });
        if (!response.ok) return { date, count: 0 };
        const data = await response.json();
        return { date, count: data.count ?? 0 };
    }));

    return results;
};


export const fetchReadingLast15Days = async (): Promise<{ date: string, count: number }[]> => {
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
        const response = await authFetch(`${apiPath}/readinglog/countPages?date=${date}`, {
            headers: { Authorization: `Bearer ${token}` },
        });
        if (!response.ok) return { date, count: 0 };
        const data = await response.json();
        return { date, count: data.count ?? 0 };
    }));

    return results;
}


export const fetchReadingsLastMonth = async (): Promise<{ date: string, count: number }[]> => {
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
        const response = await authFetch(`${apiPath}/readinglog/countPages?date=${date}`, {
            headers: { Authorization: `Bearer ${token}` },
        });
        if (!response.ok) return { date, count: 0 };
        const data = await response.json();
        return { date, count: data.count ?? 0 };
    }));

    return results;
}