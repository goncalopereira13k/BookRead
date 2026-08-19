import { apiPath } from "./apiPath";
import { authFetch } from "./authFetch";

export const fetchBookCount = async (): Promise<number> => {
    const token = localStorage.getItem("token");
    const response = await authFetch(`${apiPath}/books/all`, {
        headers: {
            Authorization: `Bearer ${token}`,
        },
    });
    if (!response.ok) {
        throw new Error('Erro ao buscar número de livros');
    }
    const books = await response.json();
    return books.length;
};

export const fetchAllBooks = async (): Promise<any[]> => {
    const token = localStorage.getItem("token");
    const response = await authFetch(`${apiPath}/books/all`, {
        headers: {
            Authorization: `Bearer ${token}`,
        },
    });
    if (!response.ok) {
        throw new Error('Erro ao buscar livros');
    }
    const books = await response.json();
    return books;
};

export const fetchBookById = async (id: string): Promise<any> => {
  const token = localStorage.getItem("token");
  const response = await authFetch(`${apiPath}/book?id=${id}`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
  if (!response.ok) {
    throw new Error('Erro ao buscar livro');
  }
  const book = await response.json();
  return book;
}


export const fetchBookCountLast7Days = async (): Promise<{ date: string; count: number }[]> => {
  const allBooks = await fetchAllBooks();

  const last7Days = Array.from({ length: 7 }, (_, i) => {
    const date = new Date();
    date.setDate(date.getDate() - i);
    return date.toISOString().slice(0, 10); // "YYYY-MM-DD"
  }).reverse();

  const counts = last7Days.map(date => {
    const count = allBooks.filter(book =>
      book.createdAt && book.createdAt.startsWith(date)
    ).length;
    return { date, count };
  });

  return counts;
};


export const fetchBookCountLast15Days = async (): Promise<{ date: string; count: number }[]> => {
  const allBooks = await fetchAllBooks();

  const last15Days = Array.from({ length: 15 }, (_, i) => {
    const date = new Date();
    date.setDate(date.getDate() - i);
    return date.toISOString().slice(0, 10); // "YYYY-MM-DD"
  }).reverse();

  const counts = last15Days.map(date => {
    const count = allBooks.filter(book =>
      book.createdAt && book.createdAt.startsWith(date)
    ).length;
    return { date, count };
  });

  return counts;
}

export const fetchBookCountLastMonth = async (): Promise<{ date: string; count: number }[]> => {
  const allBooks = await fetchAllBooks();

  const lastMonth = new Date();
  lastMonth.setDate(1); // Começa do primeiro dia do mês
  const firstDayOfLastMonth = new Date(lastMonth.getFullYear(), lastMonth.getMonth() - 1, 1);
  const lastDayOfLastMonth = new Date(lastMonth.getFullYear(), lastMonth.getMonth(), 0);

  const daysInLastMonth = [];
  for (let d = firstDayOfLastMonth; d <= lastDayOfLastMonth; d.setDate(d.getDate() + 1)) {
    daysInLastMonth.push(new Date(d).toISOString().slice(0, 10)); // "YYYY-MM-DD"
  }

  const counts = daysInLastMonth.map(date => {
    const count = allBooks.filter(book =>
      book.createdAt && book.createdAt.startsWith(date)
    ).length;
    return { date, count };
  });

  return counts;
}