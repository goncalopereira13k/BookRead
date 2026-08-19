"use client";
import React, { useEffect, useState } from "react";
import "./stats.css";
import {
  fetchUserCount,
  fetchUserCountLast7Days,
  fetchUserCountLast15Days,
  fetchUserCountLastMonth,
} from "../services/userService";
import {
  fetchBookCount,
  fetchBookCountLast7Days,
  fetchBookCountLast15Days,
  fetchBookCountLastMonth,
} from "../services/bookService";
import {
  fetchReadingsTodayCount,
  fetchReadingsLast7Days,
  fetchReadingLast15Days,
  fetchReadingsLastMonth,
} from "../services/readingsService";
import {
  fetchNotesToday,
  fetchNotesLast7Days,
  fetchNotesLast15Days,
  fetchNotesLastMonth,
} from "../services/notesService";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line } from "recharts";
import { useRouter } from "next/navigation";

export default function Estatisticas() {
  const router = useRouter();

  const [userCount, setUserCount] = useState<number | null>(null);
  const [bookCount, setBookCount] = useState<number | null>(null);
  const [readingsTodayCount, setReadingsTodayCount] = useState<number | null>(null);
  const [notesTodayCount, setNotesTodayCount] = useState<number | null>(null);

  const [usersLast7Days, setUsersLast7Days] = useState<any[]>([]);
  const [booksLast7Days, setBooksLast7Days] = useState<any[]>([]);

  // Dropdown states
  const [readingsRange, setReadingsRange] = useState<"7" | "15" | "30">("7");
  const [readingsData, setReadingsData] = useState<any[]>([]);
  const [notesRange, setNotesRange] = useState<"7" | "15" | "30">("7");
  const [notesData, setNotesData] = useState<any[]>([]);
  const [usersRange, setUsersRange] = useState<"7" | "15" | "30">("7");
  const [usersData, setUsersData] = useState<any[]>([]);
  const [booksRange, setBooksRange] = useState<"7" | "15" | "30">("7");
  const [booksData, setBooksData] = useState<any[]>([]);

  // Fetch counts and static data
  useEffect(() => {
    fetchUserCount().then(setUserCount).catch(() => setUserCount(null));
    fetchBookCount().then(setBookCount).catch(() => setBookCount(null));
    fetchReadingsTodayCount().then(setReadingsTodayCount).catch(() => setReadingsTodayCount(null));
    fetchNotesToday().then(setNotesTodayCount).catch(() => setNotesTodayCount(null));

    fetchUserCountLast7Days()
      .then(data => setUsersLast7Days(data.reverse()))
      .catch(() => setUsersLast7Days([]));

    fetchBookCountLast7Days()
      .then(data => setBooksLast7Days(data.reverse()))
      .catch(() => setBooksLast7Days([]));
  }, []);

  // Leituras - gráfico dinâmico
  useEffect(() => {
    if (readingsRange === "7") {
      fetchReadingsLast7Days().then(setReadingsData);
    } else if (readingsRange === "15") {
      fetchReadingLast15Days().then(setReadingsData);
    } else {
      fetchReadingsLastMonth().then(setReadingsData);
    }
  }, [readingsRange]);

  // Notas - gráfico dinâmico
  useEffect(() => {
    if (notesRange === "7") {
      fetchNotesLast7Days().then(setNotesData);
    } else if (notesRange === "15") {
      fetchNotesLast15Days().then(setNotesData);
    } else {
      fetchNotesLastMonth().then(setNotesData);
    }
  }, [notesRange]);

  // Registos de utilizadores - gráfico dinâmico
  useEffect(() => {
    if (usersRange === "7") {
      fetchUserCountLast7Days().then(setUsersData);
    } else if (usersRange === "15") {
      fetchUserCountLast15Days().then(setUsersData);
    } else {
      fetchUserCountLastMonth().then(setUsersData);
    }
  }, [usersRange]);

  // Livros adicionados - gráfico dinâmico
  useEffect(() => {
    if (booksRange === "7") {
      fetchBookCountLast7Days().then(setBooksData);
    } else if (booksRange === "15") {
      fetchBookCountLast15Days().then(setBooksData);
    } else {
      fetchBookCountLastMonth().then(setBooksData);
    }
  }, [booksRange]);



  useEffect(() => {
    document.body.classList.add("stats-page");
    return () => {
      document.body.classList.remove("stats-page");
    };
  }, []);

  return (
    <div className="stats-container">
      <button className="back-button" onClick={() => router.back()}>&larr; Voltar</button>

      <h2 className="stats-title">Estatísticas</h2>

      <div className="stats-cards">
        <div className="stat-card">
          <h4>Utilizadores</h4>
          <p>{userCount ?? "..."}</p>
        </div>
        <div className="stat-card">
          <h4>Livros</h4>
          <p>{bookCount ?? "..."}</p>
        </div>
        <div className="stat-card">
          <h4>Leituras Hoje</h4>
          <p>{readingsTodayCount ?? "..."}</p>
        </div>
        <div className="stat-card">
          <h4>Notas Hoje</h4>
          <p>{notesTodayCount ?? "..."}</p>
        </div>
      </div>

      <div className="chart-section">
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <h4 style={{ margin: 0 }}>Leituras</h4>
          <select
            value={readingsRange}
            onChange={e => setReadingsRange(e.target.value as "7" | "15" | "30")}
            style={{ marginLeft: 8 }}
          >
            <option value="7">Últimos 7 dias</option>
            <option value="15">Últimos 15 dias</option>
            <option value="30">Último mês</option>
          </select>
        </div>
        <ResponsiveContainer width="100%" height={300}>
          <BarChart data={readingsData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="date" />
            <YAxis />
            <Tooltip />
            <Bar dataKey="count" fill="#8884d8" />
          </BarChart>
        </ResponsiveContainer>
      </div>

      <div className="chart-section">
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <h4 style={{ margin: 0 }}>Notas</h4>
          <select
            value={notesRange}
            onChange={e => setNotesRange(e.target.value as "7" | "15" | "30")}
            style={{ marginLeft: 8 }}
          >
            <option value="7">Últimos 7 dias</option>
            <option value="15">Últimos 15 dias</option>
            <option value="30">Último mês</option>
          </select>
        </div>
        <ResponsiveContainer width="100%" height={300}>
          <BarChart data={notesData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="date" />
            <YAxis />
            <Tooltip />
            <Bar dataKey="count" fill="#ff7f50" />
          </BarChart>
        </ResponsiveContainer>
      </div>

      <div className="chart-section">
  <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
    <h4 style={{ margin: 0 }}>Registos de Utilizadores</h4>
    <select
      value={usersRange}
      onChange={e => setUsersRange(e.target.value as "7" | "15" | "30")}
      style={{ marginLeft: 8 }}
    >
      <option value="7">Últimos 7 dias</option>
      <option value="15">Últimos 15 dias</option>
      <option value="30">Último mês</option>
    </select>
  </div>
  <ResponsiveContainer width="100%" height={300}>
    <LineChart data={usersData}>
      <CartesianGrid strokeDasharray="3 3" />
      <XAxis dataKey="date" />
      <YAxis />
      <Tooltip />
      <Line type="monotone" dataKey="count" stroke="#82ca9d" strokeWidth={2} />
    </LineChart>
  </ResponsiveContainer>
</div>


      <div className="chart-section">
  <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
    <h4 style={{ margin: 0 }}>Livros adicionados</h4>
    <select
      value={booksRange}
      onChange={e => setBooksRange(e.target.value as "7" | "15" | "30")}
      style={{ marginLeft: 8 }}
    >
      <option value="7">Últimos 7 dias</option>
      <option value="15">Últimos 15 dias</option>
      <option value="30">Último mês</option>
    </select>
  </div>
  <ResponsiveContainer width="100%" height={300}>
    <LineChart data={booksData}>
      <CartesianGrid strokeDasharray="3 3" />
      <XAxis dataKey="date" />
      <YAxis />
      <Tooltip />
      <Line type="monotone" dataKey="count" stroke="#ffc658" strokeWidth={2} />
    </LineChart>
  </ResponsiveContainer>
</div>

    </div>
  );
}