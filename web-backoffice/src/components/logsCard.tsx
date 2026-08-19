"use client";
import React, { useEffect, useState } from 'react';
import { Card, ListGroup, Spinner } from 'react-bootstrap';
import { fetchRecentLogs } from '@/app/services/logsService';

interface Log {
  id: number;
  tmstamp: string;
  userId?: number;
  action: number;
}

const actionLabels: { [key: number]: string } = {
  0: "Registo",
  1: "Login",
  2: "Atualização de Perfil",
  3: "Eliminação de Perfil",
  4: "Alteração de Password",
};

const LogsCard: React.FC = () => {
  const [logs, setLogs] = useState<Log[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadLogs = async () => {
      try {
        const data = await fetchRecentLogs();
        setLogs(data);
      } catch (err: any) {
        setError(err.message || "Erro ao carregar logs");
      } finally {
        setLoading(false);
      }
    };

    loadLogs();
  }, []);

  return (
    <Card className="shadow-sm">
      <Card.Header>Últimos Logs</Card.Header>
      <ListGroup variant="flush">
        {loading ? (
          <ListGroup.Item className="text-center">
            <Spinner animation="border" size="sm" /> A carregar...
          </ListGroup.Item>
        ) : error ? (
          <ListGroup.Item className="text-danger">{error}</ListGroup.Item>
        ) : logs.length === 0 ? (
          <ListGroup.Item>Sem logs disponíveis.</ListGroup.Item>
        ) : (
          logs.map((log) => (
            <ListGroup.Item key={log.id}>
              <div><strong>Tipo:</strong> {actionLabels[log.action] ?? "Outro"}</div>
              <div><small>{new Date(log.tmstamp).toLocaleString()}</small></div>
            </ListGroup.Item>
          ))
        )}
      </ListGroup>
    </Card>
  );
};

export default LogsCard;
