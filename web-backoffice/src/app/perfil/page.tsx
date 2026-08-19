"use client";
import React, { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { fetchUser, updateUser } from "@/app/services/userService";
import "./perfil.css";

export default function Perfil() {
  const [user, setUser] = useState<any>(null);
  const [editMode, setEditMode] = useState(false);
  const [form, setForm] = useState({ username: "", email: "", birthdate: "", gender: 0 });
  const router = useRouter();

  useEffect(() => {
    fetchUser()
      .then((userData) => {
        setUser(userData);
        setForm({
          username: userData.username || "",
          email: userData.email || "",
          birthdate: userData.birthdate?.slice(0, 10) || "",
          gender: userData.gender || 0,
        });
      })
      .catch(() => setUser(null));
  }, []);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const updated = await updateUser(user.id, form);
      setUser(updated);
      setEditMode(false);
    } catch (error) {
      alert("Erro ao atualizar perfil.");
    }
  };

  const formatGender = (gender: number) => {
    switch (gender) {
      case 1: return "Masculino";
      case 2: return "Feminino";
      default: return "Outro/Não especificado";
    }
  };

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    return isNaN(date.getTime()) ? "Data inválida" : date.toLocaleDateString("pt-PT");
  };

  if (!user) {
    return (
      <div className="perfil-loading">
        <h2>A carregar perfil...</h2>
      </div>
    );
  }

  return (
    <div className="perfil-container">
      <div className="perfil-card">
        <div className="perfil-avatar">
          {user.avatar ? (
            <img src={user.avatar} alt="Avatar" style={{ width: "100%", borderRadius: "50%" }} />
          ) : (
            <span>{user.username?.[0]?.toUpperCase() || "U"}</span>
          )}
        </div>

        {editMode ? (
          <form className="perfil-form" onSubmit={handleSubmit}>
            <input name="username" value={form.username} onChange={handleChange} required />
            <input name="email" type="email" value={form.email} onChange={handleChange} required />
            <input name="birthdate" type="date" value={form.birthdate} onChange={handleChange} required />
            <select name="gender" value={form.gender} onChange={handleChange}>
              <option value={0}>Outro/Não especificado</option>
              <option value={1}>Masculino</option>
              <option value={2}>Feminino</option>
            </select>
            <div style={{ display: "flex", gap: "12px", justifyContent: "center" }}>
              <button className="perfil-voltar" type="submit">Guardar</button>
              <button className="perfil-voltar" type="button" onClick={() => setEditMode(false)}>Cancelar</button>
            </div>
          </form>
        ) : (
          <>
            <h2 className="perfil-nome">{user.username}</h2>
            <div className="perfil-info">
              <div><strong>Username:</strong> {user.username}</div>
              <div><strong>Email:</strong> {user.email}</div>
              <div><strong>Data de nascimento:</strong> {formatDate(user.birthdate)}</div>
              <div><strong>Género:</strong> {formatGender(user.gender)}</div>
            </div>
            <div style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
              <button className="perfil-voltar" onClick={() => setEditMode(true)}>Editar Perfil</button>
              <button className="perfil-voltar" onClick={() => router.push("/")}>Voltar</button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
