"use client";
import React, { useEffect, useState } from "react";
import { fetchNotesToday } from "@/app/services/notesService";

const NotesTodayCountCard: React.FC = () => {
    const [notesTodayCount, setNotesTodayCount] = useState<number | null>(null);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const loadData = async () => {
            try {
                const count = await fetchNotesToday();
                setNotesTodayCount(count);
            } catch (error) {
                console.error(error);
                setError('Erro ao carregar o número de notas hoje');
            }
        };

        loadData();
    }, []);

    return (
        <div className="p-4 bg-white rounded-xl shadow-lg">
            <h2 className="text-lg font-semibold mb-2">Notas Hoje</h2>
            {error ? (
                <p className="text-red-500">{error}</p>
            ) : (
                <p className="text-2xl font-bold">{notesTodayCount ?? 'Erro'}</p>
            )}
        </div>
    );
}

export default NotesTodayCountCard;


