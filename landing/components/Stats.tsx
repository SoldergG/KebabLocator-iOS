'use client';

import { useEffect, useRef, useState } from 'react';

const stats = [
  { value: 500, suffix: '+', label: 'Locais Disponíveis', icon: '📍', color: 'text-orange-400' },
  { value: 2000, suffix: '+', label: 'Utilizadores Ativos', icon: '👤', color: 'text-yellow-400' },
  { value: 4.9, suffix: '★', label: 'Rating App Store', icon: '⭐', color: 'text-amber-400', decimal: true },
  { value: 3, suffix: ' países', label: 'Disponível em', icon: '🌍', color: 'text-red-400' },
];

function AnimatedNumber({ value, suffix, decimal }: { value: number; suffix: string; decimal?: boolean }) {
  const [display, setDisplay] = useState(0);
  const ref = useRef<HTMLSpanElement>(null);
  const ran = useRef(false);

  useEffect(() => {
    const obs = new IntersectionObserver(
      ([e]) => {
        if (e.isIntersecting && !ran.current) {
          ran.current = true;
          const duration = 1800;
          const steps = 60;
          const step = value / steps;
          let current = 0;
          const interval = setInterval(() => {
            current = Math.min(current + step, value);
            setDisplay(current);
            if (current >= value) clearInterval(interval);
          }, duration / steps);
        }
      },
      { threshold: 0.5 }
    );
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, [value]);

  return (
    <span ref={ref}>
      {decimal ? display.toFixed(1) : Math.floor(display).toLocaleString('pt-PT')}
      {suffix}
    </span>
  );
}

export default function Stats() {
  return (
    <section id="stats" className="py-24 px-6 bg-[#08080f] relative">
      {/* Glow blob */}
      <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
        <div className="w-[600px] h-[300px] bg-primary/5 rounded-full blur-[80px]" />
      </div>

      <div className="max-w-5xl mx-auto relative z-10">
        <div className="text-center mb-14">
          <span className="text-primary text-sm font-semibold tracking-widest uppercase">
            Números
          </span>
          <h2 className="text-4xl sm:text-5xl font-black mt-3 tracking-tight">
            KebabLocator em{' '}
            <span className="gradient-text">números</span>
          </h2>
        </div>

        <div className="grid grid-cols-2 lg:grid-cols-4 gap-5">
          {stats.map((s) => (
            <div
              key={s.label}
              className="glass-card border border-white/8 rounded-2xl p-6 text-center hover:border-primary/20 transition-colors group"
            >
              <div className="text-3xl mb-3 group-hover:scale-110 transition-transform">{s.icon}</div>
              <div className={`text-3xl sm:text-4xl font-black mb-1 ${s.color}`}>
                <AnimatedNumber value={s.value} suffix={s.suffix} decimal={s.decimal} />
              </div>
              <div className="text-white/40 text-sm font-medium">{s.label}</div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
