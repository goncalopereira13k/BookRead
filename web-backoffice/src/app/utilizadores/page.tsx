"use client";

import React, { useEffect, useState } from "react";
import { Card, Table, Button, Form, Spinner } from "react-bootstrap";
import { useRouter } from "next/navigation";
import {
  fetchAllUsers,
  fetchUserCount,
  updateUserById,
  deleteUserById 

} from "@/app/services/userService";
import Modal from "react-bootstrap/Modal";
import "./users.css";

interface User {
  id: string;
  username: string;
  email: string;
  gender: number;
  createdAt: string;
}

export default function Utilizadores() {
  const [userCount, setUserCount] = useState<number | null>(null);
  const [users, setUsers] = useState<User[]>([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [modalMode, setModalMode] = useState<"view" | "edit" | null>(null);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [editData, setEditData] = useState<Partial<User>>({});
  const [saving, setSaving] = useState(false);
  const router = useRouter();

  const genderLabels = ["Não definido", "Masculino", "Feminino"];

  useEffect(() => {
    fetchUserCount()
      .then(setUserCount)
      .catch(console.error);

    fetchAllUsers()
      .then((data) => {
        setUsers(data);
        setLoading(false);
      })
      .catch(console.error);
  }, []);

  const filteredUsers = users.filter((user) => {
    const username = user.username?.toLowerCase() || "";
    const email = user.email?.toLowerCase() || "";
    return (
      username.includes(searchTerm.toLowerCase()) ||
      email.includes(searchTerm.toLowerCase())
    );
  });

  const handleShowModal = async (user: User, mode: "view" | "edit") => {
   
    setSelectedUser(user);
    setEditData(user);
    setModalMode(mode);
    setShowModal(true);
  };

  const handleCloseModal = () => {
    setShowModal(false);
    setModalMode(null);
    setSelectedUser(null);
    setEditData({});
  };

  const handleEditChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target;
    setEditData((prev) => ({
      ...prev,
      [name]: name === "gender" ? Number(value) : value,
    }));
  };

  const handleSaveEdit = async () => {
    if (!selectedUser) return;
    setSaving(true);
    try {
      // Envia sempre todos os campos editáveis, sem o campo id
      const payload = {
        username: editData.username ?? selectedUser.username,
        email: editData.email ?? selectedUser.email,
        gender: editData.gender ?? selectedUser.gender
      };
      await updateUserById(selectedUser.id, payload); // Usar updateUser (PUT /user)
      const updatedUsers = await fetchAllUsers();
      setUsers(updatedUsers);
      handleCloseModal();
    } catch (err) {
      console.error(err);
      alert("Erro ao atualizar utilizador.");
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteUser = async () => {
  if (!selectedUser) return;
  
  console.log("Selected user to delete:", selectedUser);
  console.log("User ID:", selectedUser.id, "Type:", typeof selectedUser.id);
  
  const confirmDelete = window.confirm(
    `Tem a certeza que deseja eliminar o utilizador "${selectedUser.username}"? Esta ação não pode ser desfeita.`
  );
  
  if (!confirmDelete) return;
  
  setSaving(true);
  try {
    await deleteUserById(selectedUser.id);
    const updatedUsers = await fetchAllUsers();
    setUsers(updatedUsers);
    const newCount = await fetchUserCount();
    setUserCount(newCount);
    handleCloseModal();
    alert("Utilizador eliminado com sucesso.");
  } catch (err) {
    console.error(err);
    alert("Erro ao eliminar utilizador.");
  } finally {
    setSaving(false);
  }
};
    

  return (
    <div className="p-4">
      <div className="d-flex justify-content-start mb-3">
        <Button variant="secondary" onClick={() => router.push("/")}>
          Voltar
        </Button>
      </div>

      <div className="d-flex gap-3 mb-4 flex-wrap justify-content-center">
        <Card style={{ minWidth: 220 }} className="shadow-sm border-0 text-center">
          <Card.Body>
            <Card.Title>Total de Utilizadores</Card.Title>
            <Card.Text className="fs-3">
              {userCount !== null ? userCount : "..."}
            </Card.Text>
          </Card.Body>
        </Card>
      </div>

      <Form className="mb-3 w-100 d-flex justify-content-center">
        <Form.Control
          type="text"
          placeholder="Pesquisar utilizadores por nome ou email..."
          style={{ maxWidth: 400 }}
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </Form>

      {loading ? (
        <div className="text-center mt-5">
          <Spinner animation="border" />
        </div>
      ) : (
        <div className="table-responsive">
          <Table striped bordered hover className="shadow-sm">
            <thead className="table-dark">
              <tr>
                <th>Username</th>
                <th>Email</th>
                <th>Género</th>
                <th>Data de Registo</th>
                <th>Ações</th>
              </tr>
            </thead>
            <tbody>
              {filteredUsers.map((user) => (
                <tr key={user.id}>
                  <td>{user.username}</td>
                  <td>{user.email}</td>
                  <td>
                    {genderLabels[user.gender]}
                  </td>
                  <td>
                    {user.createdAt
                      ? new Date(user.createdAt).toLocaleDateString("pt-PT")
                      : "—"}
                  </td>
                  <td>
                    <Button
                      size="sm"
                      variant="primary"
                      className="me-2"
                      onClick={() => handleShowModal(user, "view")}
                    >
                      Ver
                    </Button>
                    <Button
                      size="sm"
                      variant="outline-secondary"
                      onClick={() => handleShowModal(user, "edit")}
                    >
                      Editar
                    </Button>
                  </td>
                </tr>
              ))}
              {filteredUsers.length === 0 && (
                <tr>
                  <td colSpan={5} className="text-center">
                    Nenhum utilizador encontrado.
                  </td>
                </tr>
              )}
            </tbody>
          </Table>
        </div>
      )}

      <Modal show={showModal} onHide={handleCloseModal} centered>
        <Modal.Header closeButton>
          <Modal.Title>
            {modalMode === "view"
              ? "Detalhes do Utilizador"
              : "Editar Utilizador"}
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          {selectedUser && modalMode === "view" && (
            <div>
              <p>
                <strong>Username:</strong> {selectedUser.username}
              </p>
              <p>
                <strong>Email:</strong> {selectedUser.email}
              </p>
              <p>
                <strong>Género:</strong>{" "}
                {genderLabels[selectedUser.gender]}
              </p>
              <p>
                <strong>Data de Registo:</strong>{" "}
                {selectedUser.createdAt
                  ? new Date(selectedUser.createdAt).toLocaleDateString("pt-PT")
                  : "—"}
              </p>
            </div>
          )}
          {selectedUser && modalMode === "edit" && (
            <Form>
              <Form.Group className="mb-3">
                <Form.Label>Username</Form.Label>
                <Form.Control
                  name="username"
                  value={editData.username || ""}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => handleEditChange(e)}
                />
              </Form.Group>
              <Form.Group className="mb-3">
                <Form.Label>Email</Form.Label>
                <Form.Control
                  name="email"
                  value={editData.email || ""}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => handleEditChange(e)}
                />
              </Form.Group>
              <Form.Group className="mb-3">
                <Form.Label>Género</Form.Label>
                <Form.Select
                  name="gender"
                  value={editData.gender || ""}
                  onChange={(e: React.ChangeEvent<HTMLSelectElement>) => handleEditChange(e)}
                >
                  <option value="0">Não definido</option>
                  <option value="1">Masculino</option>
                  <option value="2">Feminino</option>
                </Form.Select>
              </Form.Group>
            </Form>
          )}
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={handleCloseModal}>
            Fechar
          </Button>
          {modalMode === "edit" && (
            <>
              <Button
                variant="danger"
                onClick={handleDeleteUser}
                disabled={saving}
                className="me-2"
              >
                {saving ? "A eliminar..." : "Eliminar"}
              </Button>
              <Button
                variant="primary"
                onClick={handleSaveEdit}
                disabled={saving}
              >
                {saving ? "A guardar..." : "Guardar"}
              </Button>
            </>
          )}
        </Modal.Footer>
      </Modal>
    </div>
  );
}
