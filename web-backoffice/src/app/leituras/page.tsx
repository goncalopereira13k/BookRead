"use client";

import React, { useEffect, useState } from "react";
import { Card, Table, Button, Form, Spinner } from "react-bootstrap";
import { useRouter } from "next/navigation";
import {
  fetchReadingsTodayCount,
  fetchReadingsLast7Days,
} from "@/app/services/readingsService";
import "./readings.css";

export default function Leituras() {
  const [readings, setReadings] = useState<any[]>([]);
  const [readingsCount, setReadingsCount] = useState<number | null>(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    fetchReadingsTodayCount()
      .then(setReadingsCount)
      .catch(console.error);

    fetchReadingsLast7Days()
      .then((data) => {
        setReadings(data.reverse()); // Do mais recente para o mais antigo
        setLoading(false);
      })
      .catch(console.error);
  }, []);

  const filteredReadings = readings.filter((reading) =>
    reading.date.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="p-4">
      {/* Botão voltar */}
      <div className="d-flex justify-content-start mb-3">
        <Button variant="secondary" onClick={() => router.push("/")}>
          Voltar
        </Button>
      </div>

      {/* Estatísticas */}
      <div className="d-flex gap-3 mb-4 flex-wrap justify-content-center">
        <Card style={{ minWidth: 220 }} className="shadow-sm border-0 text-center">
          <Card.Body>
            <Card.Title>Leituras de Hoje</Card.Title>
            <Card.Text className="fs-3">
              {readingsCount !== null ? readingsCount : "..."}
            </Card.Text>
          </Card.Body>
        </Card>
      </div>

      {/* Pesquisa */}
      <Form className="mb-3 w-100 d-flex justify-content-center">
        <Form.Control
          type="text"
          placeholder="Pesquisar por data (AAAA-MM-DD)..."
          style={{ maxWidth: 400 }}
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </Form>

      {/* Tabela de Leituras */}
      {loading ? (
        <div className="text-center mt-5">
          <Spinner animation="border" />
        </div>
      ) : (
        <div className="table-responsive">
          <Table striped bordered hover className="shadow-sm">
            <thead className="table-dark">
              <tr>
                <th>Data</th>
                <th>Total de Leituras</th>
              </tr>
            </thead>
            <tbody>
              {filteredReadings.map((reading) => (
                <tr key={reading.date}>
                  <td>{reading.date}</td>
                  <td>{reading.count}</td>
                </tr>
              ))}
              {filteredReadings.length === 0 && (
                <tr>
                  <td colSpan={2} className="text-center">
                    Nenhuma leitura encontrada.
                  </td>
                </tr>
              )}
            </tbody>
          </Table>
        </div>
      )}
    </div>
  );
}
