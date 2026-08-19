"use client";
import React, { useEffect, useState } from "react";
import { Bar } from "react-chartjs-2";
import { Chart, BarElement, CategoryScale, LinearScale, Tooltip, Legend } from "chart.js";
import { fetchReadingsLast7Days } from "@/app/services/readingsService";
import { get } from "http";

Chart.register(BarElement, CategoryScale, LinearScale, Tooltip, Legend);

// Função para gerar os últimos 7 dias no formato yyyy-mm-dd
function getLast7Days(): string[] {
    const days: string[] = [];
    const today = new Date();
    for (let i = 6; i >= 0; i--) {
        const d = new Date(today);
        d.setDate(today.getDate() - i);
        const yyyy = d.getFullYear();
        const mm = String(d.getMonth() + 1).padStart(2, '0');
        const dd = String(d.getDate()).padStart(2, '0');
        days.push(`${yyyy}-${mm}-${dd}`);
    }
    return days;
}

const ReadingsGraph: React.FC = () => {
    const [labels, setLabels] = useState<string[]>([]);
    const [data, setData] = useState<number[]>([]);

    useEffect(() => {
        const days = getLast7Days();
        setLabels(days);
        console.log(getLast7Days());
        fetchReadingsLast7Days().then((readings) => {
            // readings: [{ date: '2025-05-20', count: 2 }, ...]
            // Criar um mapa para acesso rápido
            const map: Record<string, number> = {};
            readings.forEach((r: any) => {
                map[r.date] = r.count;
            });
            // Preencher os dados alinhados com os dias
            setData(days.map(day => map[day] ?? 0));
        });
    }, []);

    return (
        <Bar
            data={{
                labels, // sempre os últimos 7 dias no eixo X
                datasets: [
                    {
                        label: "Leituras",
                        data, // leituras no eixo Y
                        backgroundColor: "#7c3aed",
                    },
                ],
            }}
            options={{
                responsive: true,
                plugins: {
                    legend: { display: false },
                },
                scales: {
                    x: { title: { display: true, text: "Dia" } },
                    y: {
                        title: { display: true, text: "Leituras" },
                        beginAtZero: true
                        // Removido min e max para auto scale
                    },
                },
            }}
        />
    );
};

export default ReadingsGraph;