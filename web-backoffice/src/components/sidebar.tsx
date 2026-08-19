"use client";
import React from "react";
import { Nav } from "react-bootstrap";
import { FaTachometerAlt, FaUsers, FaBook, FaBookReader, FaChartBar, FaCog, FaSignOutAlt } from "react-icons/fa";
import { IoIosNotifications } from "react-icons/io";
import { useRouter } from "next/navigation";

const Sidebar = () => {
  const router = useRouter();

  const handleLogout = () => {
    router.push("/login");
  };
  const handleUtilizadores = () => {
    router.push("/utilizadores");
  }
  const handleLivros = () => {
    router.push("/livros");
  }
  const handleDashboard = () => {
    router.push("/");
  }
  const handleLeituras = () => {
    router.push("/leituras");
  }
  const handleConfig = () => {
    router.push("/configuracoes");
  }
  const handleStats = () => {
    router.push("/estatisticas");
  }

  return (
    <div
      className="sidebar bg-light shadow-sm d-flex flex-column"
      style={{
        width: "250px",
        height: "100vh",
        position: "fixed",
        left: "0",
        top: "0px",
        padding: "1rem",
        zIndex: 1,
      }}
    >
      <h5 className="mb-4">BookRead Backoffice</h5>
      <Nav className="flex-column gap-2">
        <Nav.Link onClick={handleDashboard}><FaTachometerAlt className="me-2" />Dashboard</Nav.Link>
        <Nav.Link onClick={handleUtilizadores}><FaUsers className="me-2" />Utilizadores</Nav.Link>
        <Nav.Link onClick={handleLivros}><FaBook className="me-2" />Livros</Nav.Link>
        <Nav.Link onClick={handleLeituras}><FaBookReader className="me-2" />Leituras</Nav.Link>
        <Nav.Link onClick={handleStats}><FaChartBar className="me-2" />Estatísticas</Nav.Link>
        <Nav.Link onClick={handleLogout} className="mt-auto text-danger" style={{ cursor: "pointer" }}>
          <FaSignOutAlt className="me-2" />Sair
        </Nav.Link>
      </Nav>
    </div>
  );
};

export default Sidebar;