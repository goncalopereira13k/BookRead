"use client";
import React, { useEffect, useState } from "react";
import { fetchReadingsTodayCount } from "@/app/services/readingsService";

const ReadingsTodayCountCard: React.FC = () => {
    const [readingsTodayCount, setReadingsTodayCount] = useState<number | null>(null);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const loadData = async () => {
            try {
                const count = await fetchReadingsTodayCount();
                setReadingsTodayCount(count);
            } catch (error) {
                console.error(error);
                setError('Erro ao carregar o número de leituras hoje');
            }
        };

        loadData();
    }, []);

    return (
        <div className="p-4 bg-white rounded-xl shadow-lg">
            <h2 className="text-lg font-semibold mb-2">Leituras Hoje</h2>
            {error ? (
                <p className="text-red-500">{error}</p>
            ) : (
                <p className="text-2xl font-bold">{readingsTodayCount ?? 'Erro'}</p>
            )}
        </div>
    );
}

export default ReadingsTodayCountCard;