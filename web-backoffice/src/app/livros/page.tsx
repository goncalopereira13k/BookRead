"use client";
import React, { useEffect, useState } from "react";
import { fetchAllBooks } from "@/app/services/bookService";
import { useRouter } from "next/navigation";
import "./books.css";



export default function BooksPage() {
  const [books, setBooks] = useState<any[]>([]);
  const [currentPage, setCurrentPage] = useState(0);
  const [totalItems, setTotalItems] = useState(0);
  const [allBooks, setAllBooks] = useState<any[]>([]);
  const router = useRouter();

  const PAGE_SIZE = 12; // Quantos livros por página


  const fetchAllBooksHandler = async () => {
    try {
      const booksData = await fetchAllBooks();
      const adaptedBooks = booksData.map((entry) => ({
        id: entry.book.id,
        volumeInfo: {
          title: entry.book.title,
          imageLinks: {
            thumbnail: entry.book.imageUrl
          }
        }
      }));

      setAllBooks(adaptedBooks);
      setTotalItems(adaptedBooks.length);
      setBooks(adaptedBooks.slice(0, PAGE_SIZE));
    } catch (error) {
      console.error("Erro ao buscar livros:", error);
    }
  };


  const handlePageChange = (page: number) => {
    setCurrentPage(page);
    const start = page * PAGE_SIZE;
    const end = start + PAGE_SIZE;
    setBooks(allBooks.slice(start, end));
  };

  useEffect(() => {
    fetchAllBooksHandler();
  }, []);

  useEffect(() => {
    const start = currentPage * PAGE_SIZE;
    const end = start + PAGE_SIZE;
    setBooks(allBooks.slice(start, end));
  }, [currentPage, allBooks]);

  const totalPages = Math.ceil(totalItems / PAGE_SIZE);


  return (
    <div className="books-page">
      <h1 className="books-title">Livros Populares</h1>
      <div className="book-grid">
        {books.map((book) => {
          const info = book.volumeInfo;
          if (!info) return null; // Se não houver informações do livro, ignore
          return (
            <div
              key={book.id}
              className="book-card"
              onClick={() => {

                router.push(`/livros/${book.id}`)
              }
              }
            >
              <img
                src={info.imageLinks?.thumbnail || "/placeholder.jpg"}
                alt={info.title || "Livro sem titulo"}
              />
              <p className="book-title">{info.title || "Sem título"}</p>
            </div>
          );
        })}
      </div>

      <div className="pagination">
        {Array.from({ length: totalPages }).map((_, i) => (
          <button
            key={i}
            className={`page-btn ${i === currentPage ? "active" : ""}`}
            onClick={() => handlePageChange(i)}
          >
            {i + 1}
          </button>
        ))}
      </div>

      <button className="back-btn" onClick={() => router.push("/")}>
        Voltar à Página Principal
      </button>
    </div>
  );
}
