export default function Footer() {
  const year = new Date().getFullYear();

  return (
    <footer className="bg-[#08080f] border-t border-white/5">
      <div className="max-w-6xl mx-auto px-6 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-10 mb-10">
          {/* Brand */}
          <div className="md:col-span-2">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center text-lg">
                🌯
              </div>
              <span className="font-bold text-lg">
                Kebab<span className="text-primary">Locator</span>
              </span>
            </div>
            <p className="text-white/40 text-sm leading-relaxed max-w-xs">
              A app iOS que ajuda todos os amantes de kebab a encontrar o local perfeito perto deles.
              Projeto escolar desenvolvido com SwiftUI.
            </p>
            <div className="flex items-center gap-3 mt-5">
              <a
                href="#download"
                className="flex items-center gap-2 bg-white/5 hover:bg-white/10 border border-white/10 text-white/70 hover:text-white text-xs font-medium px-3 py-2 rounded-lg transition-all"
              >
                🍎 App Store
              </a>
              <a
                href="https://github.com/soldergg/kebablocator-ios"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 bg-white/5 hover:bg-white/10 border border-white/10 text-white/70 hover:text-white text-xs font-medium px-3 py-2 rounded-lg transition-all"
              >
                <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z" />
                </svg>
                GitHub
              </a>
            </div>
          </div>

          {/* Links */}
          <div>
            <h4 className="text-white/70 text-sm font-semibold mb-4">App</h4>
            <ul className="space-y-2.5">
              {['Funcionalidades', 'Como Funciona', 'Estatísticas', 'Download'].map((l) => (
                <li key={l}>
                  <a
                    href={`#${l.toLowerCase().replace(/\s/g, '-')}`}
                    className="text-white/35 hover:text-white text-sm transition-colors"
                  >
                    {l}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="text-white/70 text-sm font-semibold mb-4">Projeto</h4>
            <ul className="space-y-2.5">
              {[
                { label: 'GitHub', href: 'https://github.com/soldergg/kebablocator-ios' },
                { label: 'App Store', href: '#download' },
                { label: 'Privacidade', href: '#' },
                { label: 'Termos', href: '#' },
              ].map((l) => (
                <li key={l.label}>
                  <a
                    href={l.href}
                    className="text-white/35 hover:text-white text-sm transition-colors"
                  >
                    {l.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        </div>

        {/* Bottom */}
        <div className="pt-8 border-t border-white/5 flex flex-col sm:flex-row items-center justify-between gap-4">
          <p className="text-white/25 text-xs">
            © {year} KebabLocator. Projeto Escolar. Desenvolvido com 🌯 e SwiftUI.
          </p>
          <div className="flex items-center gap-2">
            <div className="w-1.5 h-1.5 rounded-full bg-green-400 animate-pulse" />
            <span className="text-white/25 text-xs">Disponível no App Store</span>
          </div>
        </div>
      </div>
    </footer>
  );
}
