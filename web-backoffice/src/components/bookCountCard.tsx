"use client";
import { useEffect, useState } from 'react';
import { fetchBookCount } from '@/app/services/bookService';

const BookCountCard: React.FC = () => {
    const [bookCount, setBookCount] = useState<number | null>(null);
    const [error, setError] = useState<string | null>(null);
    useEffect(() => {
        const loadData = async () => {
            try {
                const count = await fetchBookCount();
                setBookCount(count);
            } catch (error) {
                console.error(error);
                setError('Erro ao carregar o número de livros');
            }
        };

        loadData();
    }, []);

    return (
        <div className="p-4 bg-white rounded-xl shadow-lg">
            <h2 className="text-lg font-semibold mb-2">Número de Livros</h2>
            {error ? (
                <p className="text-red-500">{error}</p>
            ) : (
                <p className="text-2xl font-bold">{bookCount ?? 'Erro'}</p>
            )}
        </div>
    );
}
export default BookCountCard;