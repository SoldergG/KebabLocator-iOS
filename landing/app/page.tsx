import dynamic from 'next/dynamic';
import Navbar from '@/components/Navbar';
import Features from '@/components/Features';
import HowItWorks from '@/components/HowItWorks';
import Stats from '@/components/Stats';
import Download from '@/components/Download';
import Footer from '@/components/Footer';

const Hero = dynamic(() => import('@/components/Hero'), { ssr: false });

export default function Home() {
  return (
    <main className="relative">
      <Navbar />
      <Hero />
      <div className="section-divider" />
      <Features />
      <div className="section-divider" />
      <HowItWorks />
      <div className="section-divider" />
      <Stats />
      <div className="section-divider" />
      <Download />
      <Footer />
    </main>
  );
}
