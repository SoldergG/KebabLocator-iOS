'use client';

import { useEffect, useRef, useState } from 'react';

const steps = [
  {
    step: '01',
    icon: '📲',
    title: 'Descarrega a App',
    description:
      'Instala o KebabLocator gratuitamente no App Store. Funciona em iPhone e iPad com iOS 16 ou superior.',
    detail: 'Grátis • iOS 16+ • iPadOS 16+',
  },
  {
    step: '02',
    icon: '🌍',
    title: 'Ativa a Localização',
    description:
      'Permite o acesso à localização e a app mostra automaticamente todos os kebabs num mapa interativo.',
    detail: 'GPS Preciso • Sem conta necessária',
  },
  {
    step: '03',
    icon: '🌯',
    title: 'Escolhe e Vai Comer',
    description:
      'Lê avaliações, vê fotos, confirma o horário e navega até ao local com um toque. Bom apetite!',
    detail: 'Avaliações • Rotas • Horários',
  },
];

export default function HowItWorks() {
  const ref = useRef<HTMLDivElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const obs = new IntersectionObserver(
      ([e]) => {
        if (e.isIntersecting) { setVisible(true); obs.disconnect(); }
      },
      { threshold: 0.1 }
    );
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  return (
    <section id="how-it-works" className="py-28 px-6 bg-[#08080f] relative overflow-hidden">
      {/* Background grid */}
      <div
        className="absolute inset-0 opacity-[0.025]"
        style={{
          backgroundImage:
            'linear-gradient(rgba(255,107,53,1) 1px,transparent 1px),linear-gradient(90deg,rgba(255,107,53,1) 1px,transparent 1px)',
          backgroundSize: '60px 60px',
        }}
      />

      <div className="max-w-5xl mx-auto relative z-10">
        {/* Header */}
        <div className="text-center mb-16">
          <span className="text-primary text-sm font-semibold tracking-widest uppercase">
            Como Funciona
          </span>
          <h2 className="text-4xl sm:text-5xl font-black mt-3 tracking-tight">
            Simples como{' '}
            <span className="gradient-text">1, 2, 3</span>
          </h2>
        </div>

        {/* Steps */}
        <div ref={ref} className="relative">
          {/* Connector line (desktop) */}
          <div className="hidden md:block absolute top-16 left-[calc(16.67%)] right-[calc(16.67%)] h-px bg-gradient-to-r from-transparent via-primary/30 to-transparent" />

          <div className="grid md:grid-cols-3 gap-8 md:gap-6">
            {steps.map((s, i) => (
              <div
                key={s.step}
                style={{ transitionDelay: `${i * 150}ms` }}
                className={`flex flex-col items-center text-center transition-all duration-700 ${
                  visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'
                }`}
              >
                {/* Step number bubble */}
                <div className="relative mb-6">
                  <div className="w-16 h-16 rounded-full bg-gradient-to-br from-primary to-secondary flex items-center justify-center text-3xl shadow-xl shadow-primary/30">
                    {s.icon}
                  </div>
                  <div className="absolute -top-2 -right-2 w-7 h-7 rounded-full bg-[#0f0f1a] border-2 border-primary flex items-center justify-center">
                    <span className="text-primary font-black text-xs">{i + 1}</span>
                  </div>
                </div>

                <div className="glass-card rounded-2xl border border-white/8 p-6 w-full">
                  <h3 className="text-white font-bold text-xl mb-3">{s.title}</h3>
                  <p className="text-white/50 text-sm leading-relaxed mb-4">{s.description}</p>
                  <div className="inline-flex items-center gap-1.5 bg-primary/10 border border-primary/20 rounded-full px-3 py-1">
                    <div className="w-1.5 h-1.5 rounded-full bg-primary" />
                    <span className="text-primary text-xs font-medium">{s.detail}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
