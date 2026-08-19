"use client";
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';
import Container from 'react-bootstrap/Container';
import Button from 'react-bootstrap/Button';
import Image from 'react-bootstrap/Image';
import Dropdown from 'react-bootstrap/Dropdown';
import React, { useEffect, useState } from 'react';
import { fetchUser } from "@/app/services/userService";
import { useRouter } from 'next/navigation';

function NavBar() {
  const router = useRouter();
  const [username, setUsername] = useState<string>("");

  useEffect(() => {
    const loadUser = async () => {
      try {
        const user = await fetchUser();
        setUsername(user.username);
      } catch (error) {
        console.error("Erro ao carregar utilizador:", error);
      }
    };

    loadUser();
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('token');
    router.push('/login');
  };

  const handlePerfil = () => {
    router.push('/perfil');
  }

  return (
    <Navbar
      bg="light"
      expand="lg"
      className="shadow-sm"
      style={{
        position: "fixed",
        top: 0,
        left: "250px",
        width: "calc(100% - 250px)",
        zIndex: 1040
      }}
    >
      <Container fluid>
        <Navbar.Toggle aria-controls="basic-navbar-nav" />
        <Navbar.Collapse id="basic-navbar-nav">
          <Nav className="me-auto"></Nav>
          <Dropdown align="end">
            <Dropdown.Toggle variant="light" id="dropdown-user" className="d-flex align-items-center border-0">
              <Image
                src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse2.mm.bing.net%2Fth%3Fid%3DOIP.pp5-j2KnQQ1XoZt0x6Q2RAHaHa%26pid%3DApi&f=1&ipt=026da6c504ee09c01cbb490a7fe855a498b9c1ae1000d67d74a27468fd3542eb&ipo=images"
                alt="User"
                width="40"
                height="40"
                roundedCircle
                className="me-2"
              />
              <span>{username || "..."}</span>
            </Dropdown.Toggle>
            <Dropdown.Menu>
              <Dropdown.Item onClick={handlePerfil}>Perfil</Dropdown.Item>
              <Dropdown.Divider />
              <Dropdown.Item onClick={handleLogout} className="text-danger">Sair</Dropdown.Item>
            </Dropdown.Menu>
          </Dropdown>
        </Navbar.Collapse>
      </Container>
    </Navbar>
  );
}

export default NavBar;
