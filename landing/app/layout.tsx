import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'KebabLocator — Encontra o Melhor Kebab Perto de Ti',
  description:
    'Descobre os melhores kebabs na tua cidade com avaliações reais, horários atualizados e localização precisa. Disponível no App Store.',
  keywords: 'kebab, localizador, ios, app, restaurante, comida',
  openGraph: {
    title: 'KebabLocator — Encontra o Melhor Kebab',
    description: 'A app que todo o amante de kebab precisava. Localização precisa, avaliações reais.',
    type: 'website',
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt" className="scroll-smooth">
      <body className="bg-[#08080f] text-white antialiased">{children}</body>
    </html>
  );
}
