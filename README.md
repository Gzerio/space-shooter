# 🚀 Space Shooter Deluxe

Um jogo de nave espacial estilo arcade desenvolvido inteiramente em **Assembly x64** para Windows!

<p align="center">
  <img src="https://github.com/Gzerio/space-shooter/blob/main/src/img/Capturar.PNG" width="45%" />
  <img src="https://github.com/Gzerio/space-shooter/blob/main/src/img/Capturar1.PNG" width="45%" />
</p>


## 📖 Sobre o Jogo

Space Shooter Deluxe é um clássico shoot 'em up onde você controla uma nave espacial e deve destruir ondas de inimigos, coletar power-ups, enfrentar bosses e acumular a maior pontuação possível!

## 🎮 Controles

| Tecla | Ação |
|-------|------|
| **A** | Mover para esquerda |
| **D** | Mover para direita |
| **W** | Mover para cima |
| **S** | Mover para baixo |
| **SPACE** | Atirar |
| **B** | Usar bomba (limpa a tela de inimigos) |
| **ESC** | Pausar/Despausar |
| **ENTER** | Confirmar (menus) |

## ⭐ Características

### Sistema de Waves
- Inimigos aparecem em ondas progressivamente mais difíceis
- A cada wave, mais inimigos aparecem e ficam mais rápidos
- Boss aparece a cada 3 waves!

### Power-ups
Ao destruir inimigos, há chance de dropar power-ups:

| Power-up | Cor | Efeito |
|----------|-----|--------|
| 🔫 **Double Shot** | Ciano | Adiciona balas extras em spread |
| 🛡️ **Escudo** | Roxo | Protege de um hit |
| ⚡ **Velocidade** | Amarelo | Aumenta velocidade temporariamente |
| ❤️ **Vida** | Rosa | Recupera uma vida |

### Sistema de Moedas e Upgrades
- Inimigos dropam moedas ao morrer
- A cada 5 waves, aparece a **Loja de Upgrades**:

| Upgrade | Custo | Efeito |
|---------|-------|--------|
| **[1] Velocidade** | 5 moedas | Aumenta velocidade de movimento |
| **[2] Cadência** | 5 moedas | Aumenta velocidade de tiro |
| **[3] Balas** | 8 moedas | Adiciona mais balas (máx 4) |

### Outros Sistemas
- **Sistema de Combo**: Mate inimigos rapidamente para multiplicar pontos!
- **Bombas**: Comece com 3 bombas que limpam todos os inimigos da tela
- **Sistema de Vidas**: 5 vidas, com invencibilidade temporária ao ser atingido
- **High Score**: Sua maior pontuação é salva automaticamente!
- **Efeitos Visuais**: Explosões, partículas, parallax nas estrelas

## 🛠️ Compilação

### Pré-requisitos
- **Visual Studio** com ferramentas de desenvolvimento C++ instaladas
- **MASM (ml64.exe)** - incluído no Visual Studio

### Instruções

1. Abra o **x64 Native Tools Command Prompt for VS**
   - Procure por "x64 Native Tools Command Prompt" no menu iniciar
   - Ou acesse via: Visual Studio → Tools → Command Line → Developer Command Prompt

2. Navegue até a pasta do projeto:
   ```cmd
   cd caminho\para\teste\src
   ```

3. Compile o assembly:
   ```cmd
   ml64 /c game.asm
   ```

4. Link o executável:
   ```cmd
   link /SUBSYSTEM:WINDOWS /ENTRY:main game.obj user32.lib kernel32.lib gdi32.lib
   ```

5. Execute o jogo:
   ```cmd
   game.exe
   ```

### Comando único (copiar e colar)
```cmd
ml64 /c game.asm && link /SUBSYSTEM:WINDOWS /ENTRY:main game.obj user32.lib kernel32.lib gdi32.lib && game.exe
```

## 📁 Estrutura do Projeto

```
teste/
├── README.md
└── src/
    └── game.asm    # Código fonte completo do jogo
```

## 🎯 Dicas de Gameplay

1. **Colete moedas!** - Elas são essenciais para comprar upgrades
2. **Use bombas com sabedoria** - Guarde para situações de emergência ou bosses
3. **Mantenha o combo** - Mate inimigos rapidamente para multiplicar pontos
4. **Pegue o escudo** - É o power-up mais valioso, te salva de um hit
5. **Upgrade de balas primeiro** - Mais balas = mais dano = mais moedas

## 🔧 Detalhes Técnicos

- **Linguagem**: Assembly x64 (MASM)
- **API**: Win32 (GDI para gráficos)
- **Renderização**: Double buffering com FillRect
- **Input**: GetAsyncKeyState para controles responsivos
- **Timer**: WM_TIMER para game loop (~60 FPS)

## 📝 Licença

Este projeto é livre para uso educacional e pessoal.

---

**Desenvolvido com 💜 em Assembly x64**
