'use client';

import { useEffect, useRef } from 'react';
import * as THREE from 'three';

export default function Hero() {
  const mountRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = mountRef.current;
    if (!el) return;

    const W = el.clientWidth;
    const H = el.clientHeight;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setSize(W, H);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.setClearColor(0x000000, 0);
    el.appendChild(renderer.domElement);

    // Scene & Camera
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(55, W / H, 0.1, 100);
    camera.position.set(0, 0, 8);

    // ─── Globe ───────────────────────────────────────────────────────────────
    const globeGroup = new THREE.Group();
    scene.add(globeGroup);

    const globeGeo = new THREE.SphereGeometry(2.6, 24, 24);
    const globeMat = new THREE.MeshBasicMaterial({
      color: 0xff6b35,
      wireframe: true,
      transparent: true,
      opacity: 0.14,
    });
    const globe = new THREE.Mesh(globeGeo, globeMat);
    globeGroup.add(globe);

    // Inner atmosphere glow
    const atmGeo = new THREE.SphereGeometry(2.62, 32, 32);
    const atmMat = new THREE.MeshBasicMaterial({
      color: 0xff4500,
      transparent: true,
      opacity: 0.04,
    });
    globeGroup.add(new THREE.Mesh(atmGeo, atmMat));

    // ─── Location pins on globe surface ──────────────────────────────────────
    const pinData = [
      [0.8, 1.0], [2.2, 0.7], [3.8, 1.3], [5.0, 0.5],
      [1.5, 2.2], [4.5, 2.0], [0.2, 0.9], [3.0, 1.8],
    ];

    const pinColor = new THREE.Color(0xff6b35);
    const pinMat = new THREE.MeshBasicMaterial({ color: pinColor });
    const pinGeo = new THREE.SphereGeometry(0.07, 8, 8);

    pinData.forEach(([theta, phi]) => {
      const r = 2.68;
      const pin = new THREE.Mesh(pinGeo, pinMat);
      pin.position.set(
        r * Math.sin(phi) * Math.cos(theta),
        r * Math.cos(phi),
        r * Math.sin(phi) * Math.sin(theta)
      );
      globeGroup.add(pin);

      // Pulse ring around each pin
      const ringGeo = new THREE.RingGeometry(0.1, 0.14, 16);
      const ringMat = new THREE.MeshBasicMaterial({
        color: 0xff6b35,
        transparent: true,
        opacity: 0.4,
        side: THREE.DoubleSide,
      });
      const ring = new THREE.Mesh(ringGeo, ringMat);
      ring.position.copy(pin.position);
      ring.lookAt(0, 0, 0);
      globeGroup.add(ring);
    });

    // ─── Orbit ring ───────────────────────────────────────────────────────────
    const orbitGeo = new THREE.TorusGeometry(3.5, 0.008, 8, 120);
    const orbitMat = new THREE.MeshBasicMaterial({
      color: 0xff6b35,
      transparent: true,
      opacity: 0.18,
    });
    const orbit = new THREE.Mesh(orbitGeo, orbitMat);
    orbit.rotation.x = Math.PI / 4;
    orbit.rotation.z = Math.PI / 6;
    scene.add(orbit);

    // Dot on orbit (satellite)
    const satGeo = new THREE.SphereGeometry(0.09, 8, 8);
    const satMat = new THREE.MeshBasicMaterial({ color: 0xffd60a });
    const satellite = new THREE.Mesh(satGeo, satMat);
    orbit.add(satellite);

    // ─── Particles ────────────────────────────────────────────────────────────
    const COUNT = 600;
    const positions = new Float32Array(COUNT * 3);
    const colors = new Float32Array(COUNT * 3);
    for (let i = 0; i < COUNT; i++) {
      const r = 4 + Math.random() * 12;
      const theta = Math.random() * Math.PI * 2;
      const phi = Math.acos(2 * Math.random() - 1);
      positions[i * 3] = r * Math.sin(phi) * Math.cos(theta);
      positions[i * 3 + 1] = r * Math.sin(phi) * Math.sin(theta);
      positions[i * 3 + 2] = r * Math.cos(phi);

      const t = Math.random();
      colors[i * 3] = 1;
      colors[i * 3 + 1] = 0.42 * t;
      colors[i * 3 + 2] = 0.21 * t;
    }

    const partGeo = new THREE.BufferGeometry();
    partGeo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    partGeo.setAttribute('color', new THREE.BufferAttribute(colors, 3));

    const partMat = new THREE.PointsMaterial({
      size: 0.04,
      vertexColors: true,
      transparent: true,
      opacity: 0.55,
      sizeAttenuation: true,
    });
    const particles = new THREE.Points(partGeo, partMat);
    scene.add(particles);

    // ─── Mouse parallax ───────────────────────────────────────────────────────
    let mouseX = 0;
    let mouseY = 0;
    const onMouseMove = (e: MouseEvent) => {
      mouseX = (e.clientX / window.innerWidth - 0.5) * 2;
      mouseY = -(e.clientY / window.innerHeight - 0.5) * 2;
    };
    window.addEventListener('mousemove', onMouseMove);

    // ─── Resize ───────────────────────────────────────────────────────────────
    const onResize = () => {
      if (!el) return;
      const w = el.clientWidth;
      const h = el.clientHeight;
      camera.aspect = w / h;
      camera.updateProjectionMatrix();
      renderer.setSize(w, h);
    };
    window.addEventListener('resize', onResize);

    // ─── Animation loop ───────────────────────────────────────────────────────
    let animId: number;
    let t = 0;

    const animate = () => {
      animId = requestAnimationFrame(animate);
      t += 0.008;

      globeGroup.rotation.y = t * 0.12;
      globeGroup.rotation.x = Math.sin(t * 0.07) * 0.08;

      orbit.rotation.z += 0.004;

      // Satellite position along orbit
      const orbitR = 3.5;
      satellite.position.set(Math.cos(t * 0.6) * orbitR, 0, Math.sin(t * 0.6) * orbitR);

      particles.rotation.y += 0.0006;
      particles.rotation.x += 0.0002;

      // Camera parallax
      camera.position.x += (mouseX * 0.5 - camera.position.x) * 0.04;
      camera.position.y += (mouseY * 0.3 - camera.position.y) * 0.04;
      camera.lookAt(0, 0, 0);

      renderer.render(scene, camera);
    };
    animate();

    return () => {
      cancelAnimationFrame(animId);
      window.removeEventListener('mousemove', onMouseMove);
      window.removeEventListener('resize', onResize);
      renderer.dispose();
      if (renderer.domElement.parentNode === el) {
        el.removeChild(renderer.domElement);
      }
    };
  }, []);

  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden bg-[#08080f]">
      {/* Three.js canvas */}
      <div ref={mountRef} className="absolute inset-0 z-0" />

      {/* Radial gradient overlay */}
      <div className="absolute inset-0 z-0 pointer-events-none">
        <div className="absolute inset-0 bg-[radial-gradient(ellipse_60%_50%_at_50%_50%,rgba(255,107,53,0.08),transparent)]" />
        <div className="absolute bottom-0 left-0 right-0 h-48 bg-gradient-to-t from-[#08080f] to-transparent" />
      </div>

      {/* Content */}
      <div className="relative z-10 text-center px-6 max-w-5xl mx-auto pt-24">
        {/* Badge */}
        <div className="inline-flex items-center gap-2 bg-primary/10 border border-primary/20 rounded-full px-4 py-2 mb-8 animate-fade-up">
          <span className="w-2 h-2 rounded-full bg-primary animate-pulse-slow" />
          <span className="text-primary text-sm font-medium tracking-wide">
            Disponível no App Store — Grátis
          </span>
        </div>

        {/* Title */}
        <h1 className="text-5xl sm:text-7xl md:text-8xl font-black tracking-tighter mb-6 animate-fade-up delay-100">
          Encontra o{' '}
          <span className="gradient-text glow-text">Melhor Kebab</span>
          <br />
          <span className="text-white/90">Perto de Ti</span>
        </h1>

        {/* Subtitle */}
        <p className="text-lg sm:text-xl text-white/50 max-w-2xl mx-auto mb-10 leading-relaxed animate-fade-up delay-200">
          KebabLocator é a app que todo o amante de kebab precisava.
          Localização precisa, avaliações reais e horários sempre atualizados — tudo no teu iPhone.
        </p>

        {/* CTAs */}
        <div className="flex flex-wrap items-center justify-center gap-4 animate-fade-up delay-300">
          <a
            href="#download"
            className="group flex items-center gap-3 bg-white text-black px-8 py-4 rounded-2xl font-bold text-base hover:bg-white/90 transition-all shadow-2xl shadow-white/10 hover:-translate-y-1"
          >
            <svg className="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
              <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
            </svg>
            Download no App Store
          </a>
          <a
            href="#features"
            className="flex items-center gap-2 border border-white/15 text-white/80 hover:text-white hover:border-white/30 px-8 py-4 rounded-2xl font-semibold text-base transition-all hover:-translate-y-1"
          >
            Ver Funcionalidades
            <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M5 12h14M12 5l7 7-7 7" />
            </svg>
          </a>
        </div>

        {/* Social proof */}
        <div className="mt-16 flex items-center justify-center gap-8 animate-fade-up delay-400">
          <div className="text-center">
            <div className="text-2xl font-black gradient-text-orange">4.9★</div>
            <div className="text-xs text-white/40 mt-1">App Store</div>
          </div>
          <div className="w-px h-10 bg-white/10" />
          <div className="text-center">
            <div className="text-2xl font-black text-white">+2K</div>
            <div className="text-xs text-white/40 mt-1">Utilizadores</div>
          </div>
          <div className="w-px h-10 bg-white/10" />
          <div className="text-center">
            <div className="text-2xl font-black text-white">100%</div>
            <div className="text-xs text-white/40 mt-1">Grátis</div>
          </div>
        </div>
      </div>

      {/* Scroll indicator */}
      <div className="absolute bottom-8 left-1/2 -translate-x-1/2 z-10 flex flex-col items-center gap-2 animate-bounce">
        <span className="text-xs text-white/30 tracking-widest uppercase">Scroll</span>
        <div className="w-px h-8 bg-gradient-to-b from-white/20 to-transparent" />
      </div>
    </section>
  );
}
