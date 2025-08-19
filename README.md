# ⚽ Brasfoot Modernizado

Um jogo de gerenciamento de futebol moderno inspirado no clássico Brasfoot, desenvolvido em Flutter com Clean Architecture e GetX.

## 🎯 Sobre o Projeto

O Brasfoot Modernizado traz a nostalgia do futebol catarinense com tecnologia moderna. Gerencie times dos campeonatos de Santa Catarina com um motor de simulação realista baseado em dados reais.

### ✨ Características Principais

- 🏗️ **Clean Architecture** - Código organizado seguindo princípios SOLID
- 🎮 **Motor de Simulação Realista** - Baseado em fatores como forma, cansaço, fator casa
- 🏆 **Campeonatos Catarinenses** - Série A, B e C com times autênticos
- 📱 **Flutter Web** - Interface moderna e responsiva
- ⚡ **GetX State Management** - Gerenciamento de estado reativo e eficiente
- 🎨 **UI Moderna** - Design limpo com tema escuro

## 🏗️ Arquitetura

```
lib/
├── constants/          # Constantes da aplicação
├── controllers/        # Estado reativo (GetX)
├── core/              # Lógica de negócio
├── models/            # Estruturas de dados
├── services/          # Serviços externos
├── ui/               # Interface do usuário
└── utils/            # Utilitários e extensões
```

### 🎯 Princípios SOLID Aplicados

- **S** - Single Responsibility: Cada classe tem uma única responsabilidade
- **O** - Open/Closed: Extensível sem modificar código existente
- **L** - Liskov Substitution: Interfaces consistentes
- **I** - Interface Segregation: Separação clara entre camadas
- **D** - Dependency Inversion: Dependências abstraídas

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)

### Instalação

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/brasfoot-modernizado.git

# Entre no diretório
cd brasfoot-modernizado

# Instale as dependências
flutter pub get

# Execute o projeto
flutter run -d web-server --web-port 8080
```

### 🌐 Demo Web

Acesse a demo online: [Brasfoot Modernizado Demo](https://seu-usuario.github.io/brasfoot-modernizado)

## 🎮 Funcionalidades

### ⚽ Motor de Simulação

- **Fator Casa/Visitante** - Times jogam melhor em casa
- **Forma Atual** - Performance recente afeta os resultados
- **Cansaço** - Fadiga impacta no desempenho
- **Rivalidades** - Clássicos são mais intensos
- **Histórico** - Tradição e títulos influenciam

### 🏆 Campeonatos Disponíveis

- **Série A** - Elite do futebol catarinense (Avaí, Figueirense, Chapecoense, etc.)
- **Série B** - Segunda divisão com times em ascensão
- **Série C** - Terceira divisão com clubes em desenvolvimento

### 📊 Recursos

- Tabela de classificação em tempo real
- Simulação rodada por rodada ou completa
- Estatísticas detalhadas dos times
- Histórico de partidas
- Interface responsiva

## 🛠️ Tecnologias

- **Flutter** - Framework de desenvolvimento
- **GetX** - Gerenciamento de estado
- **Dart** - Linguagem de programação
- **Clean Architecture** - Padrão arquitetural

## 📱 Plataformas Suportadas

- ✅ Web (Chrome, Firefox, Safari, Edge)
- ✅ Windows Desktop
- ✅ macOS Desktop
- ✅ Linux Desktop
- 🔄 Mobile (em desenvolvimento)

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### 📋 Roadmap

- [ ] Testes unitários e de integração
- [ ] Modo multiplayer online
- [ ] Sistema de transferências
- [ ] Campeonatos brasileiros
- [ ] App mobile nativo
- [ ] Modo carreira completo

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 🎯 Inspiração

Inspirado no clássico jogo Brasfoot, este projeto moderniza a experiência mantendo a simplicidade e diversão do original, mas com tecnologia atual e foco no futebol catarinense.

## 🌟 Agradecimentos

- Comunidade Flutter
- Times de futebol de Santa Catarina
- Fãs do Brasfoot original

---

**Desenvolvido com ❤️ para os amantes do futebol catarinense**

⚽ *Do Contestado ao Litoral, o futebol catarinense em suas mãos!*
