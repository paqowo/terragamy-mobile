import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';

const logoSrc = `${import.meta.env.BASE_URL}logo.webp`;

const Home: React.FC = () => {
  const [isDarkMode, setIsDarkMode] = useState(() => {
    const storedTheme = localStorage.getItem('theme');
    return storedTheme ? storedTheme === 'dark' : true; // Default to dark
  });

  useEffect(() => {
    document.documentElement.classList.toggle('dark', isDarkMode);
    localStorage.setItem('theme', isDarkMode ? 'dark' : 'light');
  }, [isDarkMode]);

  const toggleTheme = () => {
    setIsDarkMode(prevMode => !prevMode);
  };

  return (
    <div className="relative min-h-screen w-full flex flex-col items-center justify-center bg-transparent transition-colors duration-700">
      
      {/* 1. THEME TOGGLE - Úplně mimo hlavní tok (Floating) */}
      <div className="absolute top-8 right-8 z-50">
        <button 
          onClick={toggleTheme} 
          className="p-2 transition-all duration-500 hover:scale-110 group"
          aria-label="Toggle Theme"
        >
          {isDarkMode ? (
            /* SUN ICON - GOLDEN */
            <svg 
              width="28" height="28" viewBox="0 0 24 24" fill="none" 
              stroke="#D4AF37" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"
              style={{ filter: 'drop-shadow(0 0 8px rgba(212, 175, 55, 0.8))' }}
            >
              <circle cx="12" cy="12" r="5" fill="#D4AF37" fillOpacity="0.2" />
              <line x1="12" y1="1" x2="12" y2="3" /><line x1="12" y1="21" x2="12" y2="23" />
              <line x1="4.22" y1="4.22" x2="5.64" y2="5.64" /><line x1="18.36" y1="18.36" x2="19.78" y2="19.78" />
              <line x1="1" y1="12" x2="3" y2="12" /><line x1="21" y1="12" x2="23" y2="12" />
              <line x1="4.22" y1="19.78" x2="5.64" y2="18.36" /><line x1="18.36" y1="5.64" x2="19.78" y2="4.22" />
            </svg>
          ) : (
            /* MOON ICON - SUBTLE */
            <svg 
              width="28" height="28" viewBox="0 0 24 24" fill="none" 
              stroke="#383530" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"
              className="opacity-40"
            >
              <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
            </svg>
          )}
        </button>
      </div>

      {/* 2. MAIN CONTENT - Dokonale vycentrovaný */}
      <main className="min-h-screen flex flex-col items-center justify-center px-6 space-y-16 animate-in fade-in duration-1000">
        
        {/* LOGO SECTION */}
        <div className="lux-shimmer p-4 rounded-full transition-transform duration-700 hover:scale-105">
          {/* Logo click stays inside app (no external redirect). */}
          <Link to="/">
            <img 
              src={logoSrc} 
              alt="Terragramy Logo" 
              style={{ filter: 'drop-shadow(0 0 25px rgba(201, 162, 77, 0.2))' }}
              className="w-48 md:w-56 h-auto"
            />
          </Link>
        </div>

        {/* NAVIGATION CARDS */}
        <div className="w-full max-w-sm grid grid-cols-2 gap-8">
          <Link 
            to="/daily"
            className="group surface-card aspect-[2/3] rounded-[40px] lux-shimmer relative overflow-hidden hover:-translate-y-2 transition-all duration-500 flex flex-col items-center justify-center p-6 text-center"
          >
            <div className="symbol-glow-effect mb-4">
              <svg width="60" height="60" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" className="opacity-60 text-[color:var(--gold)]">
                <circle cx="9" cy="12" r="6" stroke="currentColor" strokeWidth="0.8"/>
                <circle cx="15" cy="12" r="6" stroke="currentColor" strokeWidth="0.8"/>
                <circle cx="12" cy="12" r="0.5" fill="currentColor"/>
              </svg>
            </div>
            <span className="text-[color:var(--text)] font-serif tracking-widest text-sm uppercase">Karta dne</span>
            <span className="text-[10px] text-[color:var(--muted)] mt-2 leading-relaxed opacity-80 uppercase tracking-widest">Prožitek okamžiku</span>
          </Link>

          <Link 
            to="/gallery"
            className="group surface-card aspect-[2/3] rounded-[40px] lux-shimmer relative overflow-hidden hover:-translate-y-2 transition-all duration-500 flex flex-col items-center justify-center p-6 text-center"
          >
            <div className="symbol-glow-effect mb-4">
              <svg width="60" height="60" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" className="opacity-60 text-[color:var(--gold)]">
                <circle cx="12" cy="12" r="3.5" stroke="currentColor" strokeWidth="0.8"/>
                <circle cx="12" cy="8.5" r="3.5" stroke="currentColor" strokeWidth="0.8"/>
                <circle cx="12" cy="15.5" r="3.5" stroke="currentColor" strokeWidth="0.8"/>
                <circle cx="15.03" cy="10.25" r="3.5" stroke="currentColor" strokeWidth="0.8"/>
                <circle cx="8.97" cy="10.25" r="3.5" stroke="currentColor" strokeWidth="0.8"/>
                <circle cx="15.03" cy="13.75" r="3.5" stroke="currentColor" strokeWidth="0.8"/>
                <circle cx="8.97" cy="13.75" r="3.5" stroke="currentColor" strokeWidth="0.8"/>
              </svg>
            </div>
            <span className="text-[color:var(--text)] font-serif tracking-widest text-sm uppercase">Galerie</span>
            <span className="text-[10px] text-[color:var(--muted)] mt-2 leading-relaxed opacity-80 uppercase tracking-widest">Svatyně kvalit</span>
          </Link>
        </div>
      </main>
      


    </div>
  );
};

export default Home;
