'use client';

import { useEffect, useRef, useState } from 'react';

export default function Download() {
  const ref = useRef<HTMLDivElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const obs = new IntersectionObserver(
      ([e]) => { if (e.isIntersecting) { setVisible(true); obs.disconnect(); } },
      { threshold: 0.2 }
    );
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);

  return (
    <section id="download" className="py-28 px-6 bg-[#08080f] relative overflow-hidden">
      {/* Background decoration */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        <div className="absolute -top-32 -right-32 w-96 h-96 bg-primary/8 rounded-full blur-3xl" />
        <div className="absolute -bottom-32 -left-32 w-96 h-96 bg-secondary/8 rounded-full blur-3xl" />
        <div className="absolute inset-0 bg-[radial-gradient(ellipse_80%_60%_at_50%_50%,rgba(255,107,53,0.05),transparent)]" />
      </div>

      <div ref={ref} className="max-w-4xl mx-auto relative z-10">
        <div
          className={`gradient-border transition-all duration-700 ${
            visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'
          }`}
        >
          <div className="bg-[#0f0f1a] rounded-2xl p-10 md:p-16 text-center">
            {/* Emoji stack */}
            <div className="flex items-center justify-center gap-2 text-4xl mb-6">
              <span className="animate-float" style={{ animationDelay: '0s' }}>🌯</span>
              <span className="animate-float" style={{ animationDelay: '0.4s' }}>📍</span>
              <span className="animate-float" style={{ animationDelay: '0.8s' }}>⭐</span>
            </div>

            <h2 className="text-4xl sm:text-5xl md:text-6xl font-black tracking-tight mb-4">
              Pronto para
              <br />
              <span className="gradient-text">o melhor kebab?</span>
            </h2>

            <p className="text-white/50 text-lg max-w-xl mx-auto mb-10 leading-relaxed">
              Descarrega o KebabLocator agora e descobre os kebabs escondidos da tua cidade.
              Completamente grátis, sem anúncios intrusivos.
            </p>

            {/* Buttons */}
            <div className="flex flex-wrap items-center justify-center gap-4 mb-10">
              <a
                href="https://apps.apple.com"
                target="_blank"
                rel="noopener noreferrer"
                className="group flex items-center gap-3 bg-white text-black px-8 py-4 rounded-2xl font-bold text-base hover:bg-white/90 transition-all shadow-2xl shadow-black/20 hover:-translate-y-1 hover:shadow-white/10"
              >
                <svg className="w-7 h-7 group-hover:scale-110 transition-transform" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
                <div className="text-left">
                  <div className="text-xs text-black/50 font-normal leading-none mb-0.5">Descarrega no</div>
                  <div className="font-bold leading-none">App Store</div>
                </div>
              </a>
            </div>

            {/* Requirements */}
            <div className="flex flex-wrap items-center justify-center gap-6 text-sm text-white/30">
              <span className="flex items-center gap-1.5">
                <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
                iOS 16.0+
              </span>
              <span>•</span>
              <span>iPhone & iPad</span>
              <span>•</span>
              <span>Grátis</span>
              <span>•</span>
              <span>Português & Inglês</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
