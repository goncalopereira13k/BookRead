"use client";
import React, { useEffect, useState } from "react";
import "./home.css";
import NavBar from "@/components/navbar";
import Sidebar from "@/components/sidebar";
import { Row, Col, Card, Button } from "react-bootstrap";
import Container from "react-bootstrap/Container";
import { fetchUserCount } from "@/app/services/userService";
import { fetchBookCount } from "@/app/services/bookService";
import { fetchReadingsTodayCount } from "@/app/services/readingsService";
import { fetchNotesToday } from "@/app/services/notesService";
import ReadingsGraph from "@/components/readingsgraph";
import LogsCard from "@/components/logsCard";
import { useRouter } from "next/navigation";


export default function Home() {
  const [userCount, setUserCount] = useState<number | null>(null);
  const [bookCount, setBookCount] = useState<number | null>(null);
  const [readingsTodayCount, setReadingsTodayCount] = useState<number | null>(null);
  const [notesTodayCount, setNotesTodayCount] = useState<number | null>(null);
  const router = useRouter();

  useEffect(() => {
    if (typeof window !== "undefined") {
      const token = localStorage.getItem("token");
      if (!token) {
        router.push("/login");
      }
    }
  }, []);


  useEffect(() => {
    fetchUserCount()
      .then(count => setUserCount(count))
      .catch(err => {
        console.error(err);
        setUserCount(null);
      });
  }, []);
  useEffect(() => {
    fetchBookCount()
      .then(count => setBookCount(count))
      .catch(err => {
        console.error(err);
        setBookCount(null);
      });
  }, []);

  useEffect(() => {
    fetchReadingsTodayCount()
      .then(count => setReadingsTodayCount(count))
      .catch(err => {
        console.error(err);
        setReadingsTodayCount(null);
      });
  }, []);

  useEffect(() => {
    fetchNotesToday()
      .then(count => setNotesTodayCount(count))
      .catch(err => {
        console.error(err);
        setNotesTodayCount(null);
      });
  }, []);


  useEffect(() => {
    document.body.classList.add("main-page");
    return () => {
      document.body.classList.remove("main-page");
    };

  }, []);

  return (
    <>
      {/* Fundo roxo na metade superior */}
      <div
        style={{
          position: "fixed",
          top: 0,
          left: 0,
          width: "100vw",
          height: "50vh",
          background: "var(--linear-gradient)",
          zIndex: 1,
        }}
      />
      <NavBar />
      <Container className="main-content" style={{ position: "relative", zIndex: 1 }}>
        <Row>
          <Col xs="auto" style={{ padding: 0 }}>
            <Sidebar />
          </Col>

          <Col md={9}>
            {/* Cards de resumo */}
            <div className="d-flex gap-3 mb-4 flex-wrap justify-content-center">
              <Card style={{ minWidth: 180 }} className="shadow-sm border-0">
                <Card.Body>
                  <Card.Title className="text-muted small">Utilizadores</Card.Title>
                  <Card.Text>
                    <span className="fs-3 fw-bold">
                      {userCount !== null ? userCount : "Não encontrado"}
                    </span>
                  </Card.Text>
                </Card.Body>
              </Card>
              {/* Os outros cards mantêm-se como estão */}
              <Card style={{ minWidth: 180 }} className="shadow-sm border-0">
                <Card.Body>
                  <Card.Title className="text-muted small">Livros</Card.Title>
                  <Card.Text>
                    <span className="fs-3 fw-bold">
                      {bookCount !== null ? bookCount : "Não encontrado"}
                    </span>
                  </Card.Text>
                </Card.Body>
              </Card>

              <Card style={{ minWidth: 180 }} className="shadow-sm border-0">
                <Card.Body>
                  <Card.Title className="text-muted small">Leituras feitas hoje</Card.Title>

                  <Card.Text>

                    <span className="fs-3 fw-bold">

                      {readingsTodayCount !== null ? readingsTodayCount : "Não encontrado"}
                    </span>

                  </Card.Text>
                </Card.Body>
              </Card>
              <Card style={{ minWidth: 180 }} className="shadow-sm border-0">
                <Card.Body>
                  <Card.Title className="text-muted small">Notas realizadas no dia</Card.Title>
                  <Card.Text>
                    <span className="fs-3 fw-bold">{notesTodayCount !== null ? notesTodayCount : "Não encontradas"
  
                      }</span>
                  </Card.Text>
                </Card.Body>
              </Card>
            </div>



            {/* Gráficos e atividades */}
            <Row>
  <Col md={8} className="mb-3">
    <Card className="shadow-sm border-0">
      <Card.Body>
        <Card.Title className="text-muted small">Leituras realizadas</Card.Title>
        <div style={{
          height: 220,
          background: "#f5f5f5",
          borderRadius: 8,
          display: "flex",
          alignItems: "center",
          justifyContent: "center"
        }}>
          <ReadingsGraph />
        </div>
      </Card.Body>
    </Card>
  </Col>

  <Col md={4} className="mb-3">
    <LogsCard />
  </Col>
</Row>
          </Col>
        </Row>
      </Container>
    </>
  );

}
