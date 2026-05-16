'use client';

import { useEffect, useRef, useState } from 'react';

const features = [
  {
    icon: '📍',
    title: 'Localização Precisa',
    description:
      'GPS de alta precisão mostra todos os kebabs num raio configurável por ti. Nunca mais andas perdido à procura de comida.',
    color: 'from-orange-500/20 to-red-500/10',
    border: 'border-orange-500/20',
    badge: 'GPS Real-Time',
  },
  {
    icon: '⭐',
    title: 'Avaliações Reais',
    description:
      'Só utilizadores que visitaram o local podem avaliar. Sem bots, sem avaliações falsas — apenas opiniões honestas.',
    color: 'from-yellow-500/20 to-orange-500/10',
    border: 'border-yellow-500/20',
    badge: 'Verificado',
  },
  {
    icon: '🕐',
    title: 'Horários Atualizados',
    description:
      'Horários em tempo real com indicação de aberto/fechado. Nunca chegues a um kebab fechado outra vez.',
    color: 'from-blue-500/20 to-indigo-500/10',
    border: 'border-blue-500/20',
    badge: 'Ao Vivo',
  },
  {
    icon: '🗺️',
    title: 'Mapa Interativo',
    description:
      'Mapa completo com pins coloridos, rotas a pé ou de carro e integração com Apple Maps e Google Maps.',
    color: 'from-green-500/20 to-teal-500/10',
    border: 'border-green-500/20',
    badge: 'Mapas iOS',
  },
  {
    icon: '🔔',
    title: 'Notificações',
    description:
      'Recebe alertas quando um novo kebab abre perto de ti ou quando o teu favorito fica com promoções.',
    color: 'from-purple-500/20 to-pink-500/10',
    border: 'border-purple-500/20',
    badge: 'Push Alerts',
  },
  {
    icon: '💨',
    title: 'Ultra Rápido',
    description:
      'Interface nativa em SwiftUI — lança em menos de 1 segundo e navega sem lag mesmo em conexões lentas.',
    color: 'from-cyan-500/20 to-blue-500/10',
    border: 'border-cyan-500/20',
    badge: 'SwiftUI Native',
  },
];

function FeatureCard({
  feature,
  index,
}: {
  feature: (typeof features)[0];
  index: number;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const obs = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setVisible(true);
          obs.disconnect();
        }
      },
      { threshold: 0.15 }
    );
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  return (
    <div
      ref={ref}
      style={{ transitionDelay: `${index * 80}ms` }}
      className={`glass-card rounded-2xl p-6 ${feature.border} border transition-all duration-700 hover:-translate-y-1 hover:shadow-xl hover:shadow-primary/5 group cursor-default ${
        visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
      }`}
    >
      {/* Badge */}
      <div className="flex items-center justify-between mb-5">
        <div
          className={`bg-gradient-to-br ${feature.color} rounded-xl w-12 h-12 flex items-center justify-center text-2xl group-hover:scale-110 transition-transform`}
        >
          {feature.icon}
        </div>
        <span className="text-xs font-semibold text-white/30 bg-white/5 px-2 py-1 rounded-full">
          {feature.badge}
        </span>
      </div>

      <h3 className="text-white font-bold text-lg mb-2">{feature.title}</h3>
      <p className="text-white/50 text-sm leading-relaxed">{feature.description}</p>
    </div>
  );
}

export default function Features() {
  return (
    <section id="features" className="py-28 px-6 bg-[#08080f]">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="text-center mb-16">
          <span className="text-primary text-sm font-semibold tracking-widest uppercase">
            Funcionalidades
          </span>
          <h2 className="text-4xl sm:text-5xl font-black mt-3 mb-4 tracking-tight">
            Tudo o que precisas para
            <br />
            <span className="gradient-text">encontrar o teu kebab</span>
          </h2>
          <p className="text-white/50 text-lg max-w-2xl mx-auto">
            Construído com tecnologia nativa iOS, o KebabLocator combina precisão, velocidade e
            simplicidade numa só app.
          </p>
        </div>

        {/* Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {features.map((f, i) => (
            <FeatureCard key={f.title} feature={f} index={i} />
          ))}
        </div>
      </div>
    </section>
  );
}
