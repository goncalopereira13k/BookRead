"use client";
import { useEffect, useState } from 'react';
import { fetchUserCount } from '@/app/services/userService';

const UserCountCard: React.FC = () => {
  const [userCount, setUserCount] = useState<number | null>(null);

  useEffect(() => {
    const loadData = async () => {
      try {
        const count = await fetchUserCount();
        setUserCount(count);
      } catch (error) {
        console.error(error);
      }
    };

    loadData();
  }, []);

  return (
    <div className="p-4 bg-white rounded-xl shadow-lg">
      <h2 className="text-lg font-semibold mb-2">Número de Utilizadores</h2>
      <p className="text-2xl font-bold">{userCount ?? 'Erro'}</p>
    </div>
  );
};

export default UserCountCard;