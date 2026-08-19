"use client";
import React, { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { fetchBookById } from "@/app/services/bookService";
import "./book.css";

export default function BookDetail() {
  const { id } = useParams();
  const router = useRouter();
  const [book, setBook] = useState<any | null>(null);

  useEffect(() => {
    if (typeof id === "string") {
      fetchBookById(id).then((data) => setBook(data)).catch(console.error);
    }
  }, [id]);


  if (!book) {
    return (
      <div className="loading-container">
        <h2>Carregando detalhes do livro...</h2>
      </div>
    );
  }
 

  return (
    <div className="book-detail-page" style={{
      maxWidth: 800,
      margin: "40px auto",
      background: "#fff",
      borderRadius: 16,
      boxShadow: "0 4px 24px rgba(0,0,0,0.08)",
      padding: 32,
      display: "flex",
      gap: 32,
      flexWrap: "wrap"
    }}>
      <div>
  <img
    src={book.imageUrl || "/placeholder.jpg"}
    alt={book.title}
    style={{
      width: 220,
      height: 320,
      objectFit: "cover",
      borderRadius: 12,
      boxShadow: "0 2px 12px rgba(0,0,0,0.10)"
    }}
  />
</div>
<div style={{ flex: 1, minWidth: 260 }}>
  <h2 style={{ marginBottom: 8 }}>{book.title}</h2>
  {book.subtitle && <h4 style={{ color: "#666", marginBottom: 16 }}>{book.subtitle}</h4>}
  <div style={{ marginBottom: 12 }}>
    <strong>Autor(es):</strong> {book.authors?.join(", ") || "Desconhecido"}
  </div>
  <div style={{ marginBottom: 12 }}>
    <strong>Categoria(s):</strong> {book.categories?.join(", ") || "Sem categoria"}
  </div>
  <div style={{ marginBottom: 12 }}>
    <strong>Editora:</strong> {book.publisher || "Desconhecida"}
  </div>
  <div style={{ marginBottom: 12 }}>
    <strong>Ano:</strong> {book.pubDate || "?"}
  </div>
  <div style={{ marginBottom: 12 }}>
    <strong>Páginas:</strong> {book.pageCount || "?"}
  </div>
  <div style={{ marginBottom: 12 }}>
    <strong>Idioma:</strong> {book.language?.toUpperCase() || "?"}
  </div>
  <div style={{ marginBottom: 16 }}>
    <strong>ISBN-10:</strong> {book.isbn10 || "-"}<br />
    <strong>ISBN-13:</strong> {book.isbn13 || "-"}
  </div>
  <div>
    <strong>Descrição:</strong>
    <div
      style={{ marginTop: 8, color: "#444" }}
      dangerouslySetInnerHTML={{ __html: book.description || "Sem descrição." }}
    />
  </div>
  <button
    className="back-btn"
    style={{ marginTop: 24 }}
    onClick={() => router.push("/livros")}
  >
    Voltar à lista
  </button>
</div>
</div>
  );
}
