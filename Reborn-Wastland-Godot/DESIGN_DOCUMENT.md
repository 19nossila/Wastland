# REBORN WASTLAND - GAME DESIGN DOCUMENT

## 1. VISÃO GERAL DO JOGO

### Título e Tagline
**"Reborn Wastland"** - *Survive. Evolve. Dominate.*

### Descrição Curta
Reborn Wastland é um jogo de sobrevivência 3D multiplayer em primeira pessoa que roda fluidamente até em computadores antigos. Inspirado em Unturned, oferece exploração de um mundo devastado por uma pandemia zumbi com foco em progressão leve e mecânicas únicas. Altamente otimizado: roda com mínimo 30-60 FPS em CPUs dual-core e GPUs DirectX 10. Junte-se a facções, desenvolva mutações genéticas, controle drones, sobreviva a climas extremos e descubra anomalias quânticas em um mundo vivo e em constante mudança.

### Gêneros Principais
- Survival
- Sandbox
- Multiplayer
- Zombie Apocalypse
- Action-Adventure

### Plataformas Alvo
- **PC Windows** (DirectX 10+ compatível)
- **Linux** (via Vulkan compatibility layer - futuro)

### Requisitos Mínimos
| Componente | Especificação |
|-----------|---------------|
| **CPU** | Intel Core 2 Duo / AMD Athlon X2 (Dual-core, 2.0+ GHz) |
| **RAM** | 4 GB |
| **GPU** | NVIDIA GeForce 400 series / AMD Radeon HD 5000 series (512 MB VRAM, DirectX 10) |
| **DirectX** | 10.0+ |
| **Storage** | 15 GB SSD/HDD |
| **Internet** | 5 Mbps (Multiplayer) |

### Requisitos Recomendados
| Componente | Especificação |
|-----------|---------------|
| **CPU** | Intel i5-4460 / AMD Ryzen 3 1200 (Quad-core, 3.0+ GHz) |
| **RAM** | 8 GB |
| **GPU** | NVIDIA GTX 1050 / AMD RX 460 (2 GB VRAM) |
| **Storage** | 20 GB SSD |

### Modelo de Monetização
**Free-to-Play com Cosméticos Opcionais**
- Skins de personagens (sem impacto gameplay)
- Acessórios decorativos para bases
- Peles exclusivas de armas (visuais apenas)
- Battle pass opcional (desbloques cosméticos)
- Sem pay-to-win

---

## 2. MECÂNICAS ORIGINAIS ÚNICAS (8 Sistemas)

### **1. SISTEMA DE MUTAÇÕES GENÉTICAS DO JOGADOR**

#### Descrição
Jogadores podem controlar sua própria evolução através de infecção zumbi progressiva. Cada mutação oferece vantagens únicas contra desvantagens, forçando decisões estratégicas.

#### Características
- **Mutações Disponíveis:**
  - **Visão Noturna**: Enxergue no escuro, mas sensibilidade a luz solar (40% de dano reduzido)
  - **Pele Blindada**: Reduz dano físico em 25%, mas aumenta consumo de comida em 30%
  - **Regeneração Acelerada**: Cura 5 HP/segundo em repouso, mas metade da velocidade de movimento
  - **Membros Aumentados**: +20% de velocidade, -10% de precisão em armas de longo alcance
  - **Sentidos Aguçados**: Detecta sons em 50m, detecta zumbis em 100m, pero consumo de energia triplicado
  - **Exoesqueleto**: Carregar 50% mais itens, mas -15% de agilidade

#### Progressão
- Começar com 0% de mutação (100% humano)
- Cada morte por zumbi = +5% mutação
- Consumir carne zumbi = +10% mutação (risco)
- Desativar mutação voluntariamente = -2% mutação por hora
- Máximo: 100% (jogador totalmente mutante, visuais distorcidos)

#### Impacto Gameplay
- Zumbis não atacam jogadores com 80%+ mutação (considerados "da raça")
- Facções humanas desconfiam de jogadores muito mutantes
- NPCs oferecem diferentes diálogos baseado em mutação
- Visualmente, corpo do jogador muda: pele cinzenta, membros alongados, olhos brilhantes

#### Sincronização Multiplayer (Netcode)
```gdscript
var mutation_level: float = 0.0  # 0-100
var active_mutations: Array = []  # Array de strings: ["night_vision", "regeneration"]
var mutation_timeout: float = 0.0

@rpc("call_group", "network", "unreliable")
func sync_mutation_state():
    pass
```

#### Otimização Low-End
- Apenas texturas de skin color shift (1 textura base, 3 overlays para cores)
- Shader simples com swaps de cor GPU
- Máximo 16 partículas de "aura mutante" em torno do jogador
- LOD extremo: sem efeitos visuais mutantes em 50m+ de distância

---

### **2. SISTEMA DE FACÇÕES DINÂMICAS COM REPUTAÇÃO PERSISTIDA**

#### Descrição
Mundo dividido em 4 facções rivais. Ações do jogador (roubos, assassinatos, alianças) afetam reputação persistentemente, alterando comportamento de NPCs, spawn de itens, e eventos.

#### Facções
1. **"Enclave Fortress"** (Militarista)
   - Objetivo: Controlar recursos estratégicos
   - Vantagem: Acesso a armas militares, uniformes
   - Desvantagem: Hostil com civis
   - Recompensas: Munição rara, documentos militares

2. **"Frontier Nomads"** (Nômades)
   - Objetivo: Exploração e comércio
   - Vantagem: Desconto em comércios, rotas seguras
   - Desvantagem: Menos firepower
   - Recompensas: Mapas, recursos raros

3. **"Green Eden"** (Ambientalista)
   - Objetivo: Reconstruir natureza, agricultura
   - Vantagem: Cultivo avançado, sementes
   - Desvantagem: Contra tecnologia pesada
   - Recompensas: Sementes premium, fertilizantes

4. **"Crimson Collective"** (Criminal)
   - Objetivo: Controle negro, roubo
   - Vantagem: Acesso a itens roubados baratos
   - Desvantagem: Perseguição constante por outras facções
   - Recompensas: Itens roubados, informações secretas

#### Mecânica de Reputação
- Escala: -100 (Inimigo Mortal) a +100 (Aliado Leal)
- Ações afetam reputação:
  - Completar missão: +10 a +25
  - Matar membro: -20 a -50
  - Roubar de depósito: -15 a -40
  - Entregar itens: +5 a +15
  - Auxiliar em combate: +8 a +20

#### Impactos Dinâmicos
- Reputação **+50+**: NPCs oferecem disconto 20%, revelam missões secretas
- Reputação **-50**: NPCs fogem, lojas fecham, guardas patrulham para matar
- Reputação **-80**: Bounty ativo, caçadores profissionais spawn próximos
- Reputação neutra: Comerciantes normais, sem eventos especiais

#### Eventos Faccionais
- **Incursões**: Facções atacam bases de rivais (10 min de combate)
- **Raids Cooperativas**: Aliados convocam para roubar de inimigos
- **Traição**: Traidores aparecem com 10% chance quando reputação cruza 0
- **Assassinatos Direcionados**: Contratos sobre jogadores com reputação muito negativa

#### Sincronização Multiplayer
```gdscript
var faction_reputation: Dictionary = {
    "enclave": 0,
    "nomads": 0,
    "eden": 0,
    "collective": 0
}

@rpc("call_group", "network", "reliable")
func update_faction_standing(faction: String, delta: int):
    faction_reputation[faction] += delta
    broadcast_to_world()
```

#### Otimização Low-End
- Reputação calculada uma vez por login (não em tempo real)
- Spawns de NPCs baseado em cache de reputação
- Máximo 4 NPCs ativos por zona
- LOD: Sem animações faccionais em 100m+

---

### **3. CLIMA EXTREMO PROCEDURAL QUE ALTERA O MAPA TEMPORARIAMENTE**

#### Descrição
Clima dinâmico que não é apenas visual - afeta mecânicas de jogo, zumbis, veículos e sobrevivência. Cada clima tem regras únicas.

#### Tipos de Clima
1. **Tempestade Tóxica** (Purple fog)
   - Duração: 5-15 minutos
   - Dano: 0.5 HP/seg fora de abrigo
   - Zumbis: +50% movimento, imunes a toxina
   - Veículos: -40% visibilidade
   - Itens: Contaminados (-20% durabilidade)
   - Estratégia: Ficar em abrigos, usar máscaras de gás

2. **Nevasca Congelante** (White fog + cold)
   - Duração: 8-20 minutos
   - Dano: -5 HP/seg se sem casaco quente
   - Zumbis: **Congelam** (ficam dormindo), -30% velocidade ao acordar
   - Veículos: Derrapam, -60% aceleração, combustível consome 2x
   - Itens de comida: Congelam (duram 3x mais)
   - Estratégia: Veículos inutilizáveis, zumbis viram aliados passivos

3. **Tempestade Elétrica** (Lightning, storm)
   - Duração: 3-10 minutos
   - Risco: 10% de ser atingido por raio (-50 HP)
   - Zumbis: Atraídos por eletricidade (+20% spawn perto de geradores)
   - Veículos: Riscos de falha elétrica (20% desligam durante tempestade)
   - Eletrônicos: -1% bateria por segundo
   - Estratégia: Desligar equipamentos, evitar metais grandes

4. **Secura Extrema** (Hot, dry)
   - Duração: 15-30 minutos
   - Dano: -2 HP/seg (sede acelerada), -50% velocidade sem água
   - Zumbis: +100% agressividade, -40% saúde (descidratados)
   - Veículos: +40% consumo combustível (superaquecimento)
   - Itens: Comida se decompõe 3x mais rápido
   - Água: Poços contaminados (-20% hidratação)
   - Estratégia: Buscas de água urgentes, zumbis vulneráveis

5. **Neblina Espessa** (Dense fog)
   - Duração: 10-25 minutos
   - Visibilidade: Reduzida para 15m
   - Zumbis: Spawn 2x mais (emboscadas fáceis)
   - Navegação: Bússola funciona
   - Sigilo: +50% efetividade
   - Estratégia: Descer em silêncio, espreitar zumbis

#### Estações Influenciam Clima
- **Primavera**: Tempestades Tóxicas (60% chance), clima neutro (40%)
- **Verão**: Secura Extrema (70%), Tempestades Elétricas (20%), temperas (10%)
- **Outono**: Neblina (40%), Tempestades Tóxicas (35%), neutro (25%)
- **Inverno**: Nevasca (65%), Secura (10%), Tempestades Elétricas (25%)

#### Previsão de Clima
- Jogadores podem ver previsão para próximas 3 horas em rádios/papers
- 10 minutos de "aviso" antes de clima extremo (vento aumentando, som estranho)

#### Sincronização Multiplayer
```gdscript
class WeatherState:
    var current_weather: String = "clear"
    var intensity: float = 0.0  # 0-1
    var duration: float = 0.0
    var remaining_time: float = 0.0

@rpc("call_group", "network", "unreliable")
func sync_weather_state(state: WeatherState):
    # Todos recebem mesma previsão
    pass
```

#### Otimização Low-End
- Fog simples (vertex shader)
- Particle count reduzido: 50-200 partículas máximo
- Sem volumetric fog (caro em low-end)
- Sem ray tracing de relâmpago
- Muito low config: Apenas core sem partículas, só modificador de cor
- Shader: 1 pass, sem pós-processamento

---

### **4. CRAFTING DE DRONES/ROBOTS PARA AUTOMAÇÃO**

#### Descrição
Construa e controle drones para farm automático, coleta de recursos, reconhecimento e defesa. Cada drone consome energia e tem limites.

#### Tipos de Drones

**Drone Scout (Reconhecimento)**
- Custo: 50 Metal Scraps, 10 Circuitos, 5 Baterias
- Função: Sobrevoar mapa, marcar zumbis/itens em 200m
- Velocidade: 15 m/s (rápido)
- Duração bateria: 15 min
- Visão: 360° câmera, transmite para HUD do jogador
- Limite: Máximo 3 drones scout simultâneos

**Drone Farmer (Coleta)**
- Custo: 80 Metal Scraps, 15 Circuitos, 8 Baterias
- Função: Coleta automática de plantas/colheitas em 20m²
- Velocidade: 3 m/s (lento)
- Duração: 20 min com bateria cheia
- Coleta: 70% da eficiência de jogador
- Limite: Máximo 2 simultâneos

**Drone Tower (Defesa)**
- Custo: 120 Metal Scraps, 20 Circuitos, 15 Baterias, 1 Arma Leve
- Função: Atira em zumbis automaticamente em 40m
- Inteligência: Prioriza zumbis próximos, evita amigos
- Duração: 30 min
- DPS: 15 (igual a rifle básico)
- Limite: Máximo 1 simultâneo
- Munição: Consome 1 bala por tiro

**Drone Explosivo (Bomba)**
- Custo: 100 Metal Scraps, 25 Circuitos, 5 Baterias, 1 TNT
- Função: Pilotável, colide com zumbis e explode
- Dano: 40 HP em raio 10m
- Duração: 10 min (ou até explodir)
- Recarga: 2 min entre usos
- Limite: Máximo 1 ativo
- Tática: One-time use para limpar áreas

#### Mecânica de Energia
- Todos drones têm bateria de 100%
- Consomem energia baseado em atividade:
  - Scout em voo: 5%/min
  - Farmer coletando: 7%/min
  - Tower disparando: 10%/min
  - Inativo: 1%/min
- Bateria recarga em "Charging Station" (crafted, 5 min recharge)

#### Pathfinding Otimizado
- Pathfinding A* simplificado (grid 5m)
- Máximo 4 waypoints por drone
- Sem navegação complexa (evita terreno acidentado)
- Comportamento: Segue linha reta + desvio de obstáculos básico

#### Sincronização Multiplayer
```gdscript
class DroneState:
    var drone_id: String
    var owner_id: String
    var position: Vector3
    var battery: float
    var active: bool
    var target: Vector3

@rpc("call_group", "network", "unreliable_ordered")
func sync_drone_position(drone_id: String, pos: Vector3, battery: float):
    # Atualiza posição do drone para outros jogadores
    pass
```

#### Otimização Low-End
- Modelo: 200 polígonos máximo por drone
- Sem skeleton rigging (rotação + scale apenas)
- Pathfinding: Grid-based, sem navmesh complexo
- Draw calls: 1 por drone
- LOD: Sem drone visível em 150m+
- Particle effects: Apenas 10 por drone (propelidor)
- Muito Low-End: Drones aparecem como sprites 2D, não 3D

---

### **5. SISTEMA DE "ECO-SISTEMAS ZUMBIS" (Evolução por Bioma)**

#### Descrição
Zumbis evoluem baseado no ambiente onde vivem. Floresta produz zumbis diferentes de desertos ou cidades. Criando progressão dinâmica e ameaça escalável.

#### Biomas e Zumbis Evoluídos

**Bioma: Cidade**
- Tipo 1: **Urban Runner** (Rápido, tipo militar)
  - Velocidade: 20 m/s (30% mais rápido)
  - Saúde: 50 HP (normal)
  - Dano: 15 (normal)
  - Habilidade: Pula obstáculos até 2m
  - Encontrado: Ruas, prédios urbanos
  
- Tipo 2: **Scavenger Horde** (Inteligência coletiva)
  - Velocidade: 8 m/s (lento)
  - Saúde: 40 HP (frágil)
  - Dano: 8 (baixo)
  - Habilidade: Ataca em grupos coordenados
  - Encontrado: Lojas, casas destruídas

**Bioma: Floresta**
- Tipo 1: **Forest Mutant** (Resistente)
  - Velocidade: 10 m/s
  - Saúde: 80 HP (+60% mais resistente)
  - Dano: 18
  - Habilidade: Regenera 2 HP/seg
  - Encontrado: Árvores, cavernas

- Tipo 2: **Camouflaged Creeper** (Predador)
  - Velocidade: 15 m/s
  - Saúde: 45 HP
  - Dano: 20 (crítico)
  - Habilidade: Se camufla entre árvores (invisível até 5m)
  - Encontrado: Florestas profundas

**Bioma: Deserto**
- Tipo 1: **Scorched Drifter** (Ressecado)
  - Velocidade: 18 m/s (rápido)
  - Saúde: 30 HP (muito frágil)
  - Dano: 12
  - Habilidade: Aumento de velocidade em areia (25% bonus)
  - Encontrado: Dunas, ruínas desérticas

**Bioma: Montanha/Neve**
- Tipo 1: **Frozen Horror** (Forte)
  - Velocidade: 5 m/s (muito lento no gelo)
  - Saúde: 120 HP (+140% resistência)
  - Dano: 22 (muito alto)
  - Habilidade: Freezeout - reduz velocidade do jogador em 50% quando próximo
  - Encontrado: Picos, cavernas geladas

#### Dinâmica Evolutiva
- Zumbis **sobrevivem** em combate = ganham +5% HP permanente (com limite de 200%)
- Zumbis **comem recursos locais** = adaptam-se (ex: florestal comendo vegetação = +regen)
- Zumbis **morrem por causa ambiental** = não evoluem
- Hierarquia: Quando 10+ zumbis do mesmo tipo se reúnem, **Alpha Zombie** spawn (+50% stats)

#### Progressão para Jogadores
- Primeiros dias: Apenas zumbis básicos urbanos (baixa ameaça)
- Dia 7+: Tipos evoluídos começam aparecer (dificuldade aumenta)
- Dia 30+: Alpha Zombies frequentes, hordas coordenadas
- Estratégia: Mudar de bioma para evitar escalação

#### Sincronização Multiplayer
```gdscript
class ZombieEcosystem:
    var biome: String
    var zombie_types: Dictionary
    var evolution_level: float = 0.0

@rpc("call_group", "network", "reliable")
func sync_ecosystem_state(biome: String, evo_level: float):
    # Todos veem mesma dificuldade zumbi
    pass
```

#### Otimização Low-End
- Tipos zumbis: Reutilizar modelo base (75% polígonos)
- Diferenças: Swap de textura, tamanho (scale), e cor
- LoD extremo: Zumbis sem animação em 50m (substituir por sprite)
- Inteligência: Pathfinding simples (apenas evita paredes)
- Máximo 50 zumbis ativos (pooling agressivo)
- Animação: Apenas 2 loops (walk, attack)

---

### **6. MECÂNICA DE "MEMÓRIAS ESPECTRAIS" (Fantasmas de Mortos)**

#### Descrição
Quando um jogador morre, seu "espectro" fica marcado no local. Outros jogadores podem ver pistas do que aconteceu e encontrar itens deixados para trás - criar lendas e storytelling emergente.

#### Como Funciona
1. **Morte do Jogador A** em Local X
   - Local fica marcado com "aura espectral" (círculo de luz azul claro)
   - Dura 48 horas de jogo (ou até ser "limpo")
   - Registra causa de morte (zumbi, player, fome, etc)

2. **Jogador B Visita Local**
   - Vê aura + mensagem tipo: "A tragic death occurred here"
   - Inspecionar aura: Revela
     - Nome do morto
     - Hora da morte (relativa)
     - Causa estimada (zumbis próximos = "mauled by undead")
     - Itens deixados: 50% do inventário do morto

3. **Itens Espectrais**
   - Itens deixados brilham levemente (diferente de drops normais)
   - Duram 24 horas
   - Ao pegar: Mensagem "You've taken [item] from [Player]'s grave"
   - Achievements para recuperar itens de conhecidos

4. **Histórias Emergentes**
   - Múltiplas mortes no mesmo local = "Cursed Zone" (zona marcada em vermelho)
   - Jogadores podem deixar "epitáfios" (mensagens até 50 caracteres)
   - Epitáfios são síncronizados globalmente (todos veem)

#### Exemplos de Histórias
- Zona com 5+ mortes consecutivas de mesma pessoa = "Serial Victim Zone"
- Zona com alternância de mortes diferentes = "Battleground"
- Única morte com mensagem épica = "Legend's Grave"

#### Sincronização Multiplayer
```gdscript
class SpectreMark:
    var position: Vector3
    var player_name: String
    var death_cause: String  # "zombie", "player", "starvation", "accident"
    var timestamp: float
    var inventory: Array
    var epitaph: String

@rpc("call_group", "network", "reliable")
func mark_death_location(mark: SpectreMark):
    # Transmite morte para todo servidor, todos veem aura
    pass
```

#### Otimização Low-End
- Visualização: Simples particle circle no chão
- Sem animação 3D (apenas rotação 2D sprite)
- Máximo 30 espectes ativos (older ones fade)
- Data armazenada em servidor (não local)
- Rendering: 1 quad + 1 texture por espectro

---

### **7. SISTEMA DE ESTAÇÕES DO ANO COM IMPACTOS PROFUNDOS**

#### Descrição
Mundo real com 4 estações (45 dias cada = 180 dias ciclo). Cada estação altera mecanicamente o jogo - não apenas cosmeticamente.

#### Primavera (Dias 1-45)
- **Clima**: Chuvoso, temperado
- **Iluminação**: 14h dia / 10h noite
- **Zumbis**: Metabolismo normal, spawn +10%
- **Plantas/Colheitas**: Velocidade crescimento +50%
- **Veículos**: Pista molhada (-20% aceleração)
- **Água**: Abundante (poços cheios)
- **Vantagens**: Farming melhor, zumbis menos ameaçadores
- **Desvantagens**: Visibilidade reduzida (chuva), doenças (+5% risco)

#### Verão (Dias 46-90)
- **Clima**: Quente, seco
- **Iluminação**: 16h dia / 8h noite
- **Zumbis**: +50% agressividade (calor aumenta agressão), decomposição rápida (fewer spawns)
- **Plantas/Colheitas**: Crescimento normal, apodrecem rápido
- **Veículos**: Combustível +30% consumo (superaquecimento)
- **Água**: Escassa (poços 50% cheios, precisa buscar)
- **Comida**: Decomposição 3x mais rápida
- **Vantagens**: Dias longos, menos frio à noite
- **Desvantagens**: Sede acelerada, comida precisa de armazenamento em freezer

#### Outono (Dias 91-135)
- **Clima**: Moderado, chuvas moderadas
- **Iluminação**: 12h dia / 12h noite (balanço)
- **Zumbis**: Spawn varia muito (clima imprevisível)
- **Plantas**: Colheita final de verão, preparação para inverno
- **Veículos**: Desempenho normal
- **Recursos**: Recursos misturados em abundância
- **Vantagens**: Melhor transição, colheita abundante
- **Desvantagens**: Clima caótico, anomalias climáticas frequentes

#### Inverno (Dias 136-180)
- **Clima**: Gélido, nevasca frequente
- **Iluminação**: 8h dia / 16h noite (muito escuro)
- **Zumbis**: -40% velocidade (congelados), -20% spawn, mas evoluem para "Frozen Horror"
- **Plantas**: Zero crescimento (hibernação), sem colheita
- **Veículos**: Derrapam (-60% aceleração), combustível +50% consumo, podem congelar (não funcionar)
- **Água**: Congelada (precisa aquecer para beber)
- **Comida**: Preserva indefinidamente
- **Recursos**: Apenas itens de frio (casacos, combustível)
- **Perigos**: Congelamento (-5 HP/min sem roupa quente), Avalanches (100 dano + knockback)
- **Vantagens**: Zumbis inativos (podem-se estabelecer seguro), menos inimigos visíveis
- **Desvantagens**: Sobrevivência é foco (não exploração)

#### Mecânica de Ano
- Progresso de estação é **global e sincronizado**
- Todos jogadores veem mesma estação
- Ciclo repete infinitamente
- Eventos especiais podem "resetar" ciclo ou pular estações

#### Sincronização Multiplayer
```gdscript
class SeasonState:
    var current_season: String  # "spring", "summer", "autumn", "winter"
    var days_in_season: int = 0  # 0-45
    var total_days: int = 0
    var daylight_hours: float = 0.0

@rpc("call_group", "network", "reliable")
func sync_season_state(season: SeasonState):
    # Todos clientes recebem mesma estação
    pass
```

#### Otimização Low-End
- Transição de estação: Shader color grade change (sem re-rendering)
- Luz direcional: Ajusta rotação (sem recalcular shadows em real-time)
- Sem particle changes por estação (reutiliza mesmas)
- Muito Low-End: Apenas color shift, sem mecânica de crescimento de plantas

---

### **8. "ZONAS DE ANOMALIA QUÂNTICA" (Eventos Raros)**

#### Descrição
Pontos aleatórios do mapa com anomalias físicas impossíveis: teleportes, gravidade invertida, clones temporários, distorções temporais. Raras, perigosas, mas recompensadoras.

#### Tipos de Anomalias

**Tipo 1: Teleport Vortex**
- Aparência: Vórtice rodando em cor roxa
- Raio: 15m
- Efeito: Jogar jogador para outro ponto do mapa aleatoriamente (1-2 km)
- Perigo: Possivelmente cair em inimigos, lava, vazio
- Recompensa: Itens únicos aparecem no destino (+50% mods raros)
- Duração: 10-15 minutos
- Chance: 3% por ciclo de 2 horas

**Tipo 2: Gravity Inversion Zone**
- Aparência: Céu invertido + gravidade contrária
- Raio: 20m
- Efeito: Gravidade invertida (-9.8 m/s² ao invés de +9.8)
- Desafio: Movimento impreciso, chance de "flotar para o espaço"
- Mecânica: Postos de gravidade invertida permitem atingir áreas normalmente inacessíveis (secrets)
- Recompensa: Acessos a caves secretas
- Duração: 5-10 minutos

**Tipo 3: Time Dilation Field**
- Aparência: Arena com efeito de "bolha" (time slow)
- Raio: 10m
- Efeito: Tempo passa 50% mais lento dentro (movimento 50% mais lento, zumbis mais lentos)
- Tática: Permite escapar de hordas, mas sair é lento
- Recompensa: Bônus de escada dentro (+30% XP, resources)
- Duração: 8 minutos

**Tipo 4: Clone Generator**
- Aparência: Portal com ecos dourados
- Raio: 15m
- Efeito: Cria clone temporário do jogador (30 segundos)
- Clone: Copia equipamento, saúde, mas sem IA própria (segue original)
- Uso tático: Clone pode distração ou duplicar força
- Risco: Zumbis confusos atacam ambos aleatoriamente
- Recompensa: Extra item duplicado se clone sai vivo
- Duração: 20 segundos clone, 2 min zona total

**Tipo 5: Temporal Storm**
- Aparência: Relâmpago saltando entre objetos
- Raio: 30m
- Efeito: Danifica eletrônicos (-50% bateria por segundo), causa dano aleatório
- Zumbis: Atraídos para zona
- Risco: -20 HP por 5 seg se atingido
- Recompensa: Cristais temporais (item especial raro)
- Duração: 15-25 minutos

#### Spawn e Distribuição
- Máximo 2-3 anomalias ativas simultaneamente no mapa
- Spawn em locais random a cada 4-6 horas
- Nunca perto de spawn de jogador (seguro)
- Notificação: Sons "estranhos" 30 segundos antes de aparecer

#### Loot de Anomalias
- **Loot exclusivo**:
  - "Anomaly Cores" (componentes technológicos raros)
  - "Quantum Crystals" (usados em crafting avançado)
  - "Distorted Weapons" (armas com efeitos únicos)
  - Blueprints tecnológicos avançados

#### Sincronização Multiplayer
```gdscript
class AnomalyZone:
    var zone_id: String
    var position: Vector3
    var anomaly_type: String
    var spawn_time: float
    var lifetime: float
    var active: bool

@rpc("call_group", "network", "reliable")
func spawn_anomaly_zone(anomaly: AnomalyZone):
    # Todos veem nova anomalia ao mesmo tempo
    pass
```

#### Otimização Low-End
- Shader distortion: 1 fragment pass (sem pós-processamento)
- Partículas: 50-100 por anomalia (reduzidas em very low)
- Modelo: Simples quad rodando
- Sem física inversa complexa (simples inverte movimento do jogador)
- Muito Low-End: Apenas sprite 2D com efeito de cor

---

## 3. MECÂNICAS PRINCIPAIS DE SOBREVIVÊNCIA

### Necessidades Expandidas
- **Fome** (0-100%): Aumenta -1% por min, morte em 100%
- **Sede** (0-100%): Aumenta -1% por min, morte em 100% (mais rápido em calor)
- **Fadiga** (0-100%): Aumenta -0.5% por ação, morte em 100%
- **Saúde** (0-100 HP): -1 HP/seg em fadiga total
- **Infecção** (0-100%): Aumenta se ferido perto de zumbis, morte em 100%
- **Temperatura** (°C): Dinâmica por estação, morte se <0°C ou >50°C

### Mutações Afetam Necessidades
- Night Vision: +50% sede (olhos secos)
- Armored Skin: +30% fome (metabólismo alto)
- Regeneration: -50% fadiga (menos cansaço)
- Enhanced Senses: +50% fadiga (estimulação constantemente)

### Exploração
- Zonas anômalas contêm loot raro
- Estações do ano alteram recursos disponíveis
- Clima afeta rotas de exploração

---

## 4. IA DOS ZUMBIS (Evolução Eco-Sistema)

### IA Adaptativa por Bioma
- Zumbis aprendem padrões do jogador (evitam traps que já foram usadas 3x)
- Coordenação em grupo aumenta com densidade zumbi
- Alpha Zombie comanda horda (comunicação sonora)

### Exemplos de Comportamento
- **Cidade**: Patrulham edifícios, perseguem barulhos
- **Floresta**: Emboscadas, se escondem entre árvores
- **Deserto**: Movem rápido em areia, desaparecem em tempestades
- **Montanha**: Movem lentamente, atacam com força

### Otimização
- LOD: Sem animação em 50m+ (sprite 2D)
- Pathfinding: Grid A* 5m (rápido)
- Pool: 100-200 zumbis cached
- Update: A cada 200ms (não em tempo real)

---

## 5. COMBATE E CRAFTING

### Armas
- **Melee**: Machado, barra de ferro, faca
- **Ranged**: Pistola, espingarda, rifle
- **Especial**: Arcos, armas artesanais (Molotov)

### Crafting
- Workbench para crafting avançado
- Receitas descobrtas por exploração
- Materiais: Metal, madeira, tecido, eletrônicos, plástico

### Drones no Combate
- Tower Drone dispara automaticamente
- Coordenação: Múltiplos drones focam mesmo alvo
- Countermeasure: Zumbis alpha destroem drones (-20% durabilidade por ataque)

---

## 6. VEÍCULOS E EXPLORAÇÃO

### Tipos de Veículos
- **Carro Civil**: Velocidade normal, frágil
- **Jipe**: Velocidade alta, durável, consumo combustível alto
- **Motocicleta**: Velocidade máxima, frágil, combustível eficiente
- **Caminhão**: Baixa velocidade, armazena 50 itens, durável

### Afetos por Clima
- Inverno: Derrapam, consomem mais combustível, podem congelar
- Verão: Superaquecimento (-1% durabilidade por min)
- Chuva: Pista molhada (-20% aceleração)
- Tempestade elétrica: Risco de falha elétrica

---

## 7. MULTIPLAYER COM NETCODE

### Sincronização
- **NetworkVariables**: Mutações, reputação facção, posição
- **RPCs**: Eventos únicos (morte, morte zumbi especial)
- **Authority**: Servidor autoriza ações críticas (crafting, facção)

### Anti-Cheat
- Servidor valida posição do jogador a cada 1 seg
- Velocidade máxima verificada
- Dano validado servidor-side

### Persistência
- Base do jogador salva em servidor
- Reputação salva permanentemente
- Itens in-game salvos em intervals

---

## 8. RECURSOS ADICIONAIS

### Mods para Novas Mutações
- Sistema de plugins para novos tipos de mutações
- Comunidade pode criar e compartilhar via Workshop
- Mods sincronizados entre servidor e clientes

---

## 9. ESTRATÉGIAS DE OTIMIZAÇÃO PARA LOW-END HARDWARE (CRÍTICA)

### 1. Rendering Pipeline
- **Built-in Render Pipeline** (não URP)
- **Vulkan + OpenGL** (compatível com DirectX 10)
- **Deferred Rendering**: Desabilitado (forward rendering)
- **Shadows**: 512x512 máximo, 1 light shadow
- **Sem Post-Processing**: FXAA apenas se GPU permite

### 2. Otimizações Específicas por Mecânica

#### Mutações
- **Shader**: 1 pass, color swap apenas (sem deformação mesh)
- **Texturas**: 1 base + 3 overlays (512x512 máximo)
- **LOD**: Sem efeitos visuais >50m

#### Drones
- **Modelo**: 200 polígonos, sem rig
- **Pathfinding**: Grid-based A* (5m cells)
- **Partículas**: 10-20 máximo por drone
- **Render**: 1 draw call, sem sombra

#### Clima
- **Fog**: Vertex shader fog (1 texture)
- **Partículas**: 50-200 máximo (reduzidas em very low)
- **Sem volumetric**: Muito caro em low-end

#### Zonas Quânticas
- **Distortion**: 1 fragment pass, sem ping-pong
- **LOD**: Reduz distortion >30m
- **Partículas**: 50 máximo

#### Zumbis
- **Modelo**: Low-poly (200-500 polígonos)
- **Animação**: 2 loops (walk, attack)
- **LOD**: Sprite 2D >50m
- **Pool**: 100-200 máximo
- **Update**: 200ms intervals

### 3. Memory Management

```gdscript
# Pooling de drones
class DronePool:
    var pool: Array = []
    var pool_size: int = 10
    
    func get_drone() -> Drone:
        if pool.is_empty():
            return Drone.new()
        return pool.pop_back()
    
    func return_drone(drone: Drone):
        drone.reset()
        pool.append(drone)

# Pooling de zumbis
class ZombiePool:
    var pool: Array = []
    var active: Array = []
    var max_active: int = 100
    
    func update():
        for zombie in active:
            zombie.update()
        
        # Remove inátivos
        if active.size() > max_active:
            var removed = active.pop_front()
            pool.append(removed)
```

### 4. Configurações por Qualidade

**Very Low (4GB RAM, Dual-core CPU)**
- Resolução: 720p
- Fog distance: 50m (fog começa antes)
- Max zombies: 30
- Sem clima dinâmico (apenas cores)
- Sem particles
- Mutações: Apenas color swap (sem efeitos)
- Drones: Não renderizam, apenas afetam gameplay
- Draw distance: 100m

**Low (4GB RAM, Quad-core CPU)**
- Resolução: 1024x768
- Fog distance: 100m
- Max zombies: 50
- Clima: Fog + color, sem particles
- Mutações: Basic shader
- Drones: Renderizam, sem sombra
- Draw distance: 150m

**Medium (8GB RAM, Quad-core CPU)**
- Resolução: 1280x720
- Fog distance: 200m
- Max zombies: 80
- Clima: Particles leves (50)
- Mutações: Shader + efeitos (20 partículas)
- Drones: Com sombra dinâmica
- Draw distance: 250m

**High (8GB+ RAM, i5+ CPU)**
- Resolução: 1920x1080
- Fog distance: 400m
- Max zombies: 150
- Clima: Particles completos (200)
- Mutações: Shader deformação + partículas (50)
- Drones: Sombras, efeitos completos
- Draw distance: 500m

### 5. Network Optimization

```gdscript
# Reduzir update frequency em multiplayer
@rpc("call_group", "network", "unreliable", 5.0)  # 5 second intervals
func sync_position(pos: Vector3):
    pass

# Compress sync data
var compressed_data = var_to_bytes(data)  # Godot automatic compression
send_sync_data(compressed_data)

# Priority-based updates
func _physics_process(delta):
    if is_multiplayer_authority():
        update_frequency = 0.1 if near_players else 0.5
```

### 6. Exemplos de Código Otimizado

#### Shader Simples para Mutação
```glsl
shader_type spatial;
render_mode cull_back, unshaded;

uniform sampler2D albedo_texture: source_color;
uniform vec3 mutation_color: hint_color = vec3(0.5, 0.7, 0.5);
uniform float mutation_intensity: hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec3 albedo = texture(albedo_texture, UV).rgb;
    vec3 mutated = mix(albedo, mutation_color, mutation_intensity);
    ALBEDO = mutated;
}
```

#### Pooling de Drones
```gdscript
class_name DroneManager extends Node

var drone_pool: Array[Drone] = []
var active_drones: Array[Drone] = []
const MAX_DRONES = 5
const POOL_SIZE = 10

func _ready():
    for i in range(POOL_SIZE):
        drone_pool.append(Drone.new())

func spawn_drone(type: String, position: Vector3) -> Drone:
    if active_drones.size() >= MAX_DRONES:
        return null
    
    var drone: Drone
    if drone_pool.is_empty():
        drone = Drone.new()
    else:
        drone = drone_pool.pop_back()
    
    drone.initialize(type, position)
    active_drones.append(drone)
    return drone

func _process(delta):
    for i in range(active_drones.size() - 1, -1, -1):
        var drone = active_drones[i]
        drone.update(delta)
        if drone.is_dead():
            active_drones.remove_at(i)
            drone_pool.append(drone)
```

---

## RESUMO EXECUTIVO

**Reborn Wastland** oferece um jogo de sobrevivência multiplayer totalmente acessível em hardware low-end, com 8 mecânicas originais que criam experiência única versus Unturned:

1. Mutações genéticas controladas dão progressão emergente
2. Facções dinâmicas criam política persistida
3. Clima extremo muda estratégia a cada momento
4. Drones adicionam camada de automação tática
5. Eco-sistemas zumbis tornam cada bioma desafiador
6. Memórias espectrais criam narrativas de morte
7. Estações reais impõem ciclos de sobrevivência
8. Anomalias quânticas adicionam mistério e loot raro

**Resultado**: Jogo realmente diferente, não apenas "Unturned em Godot", rodando em qualquer PC antigo com qualidade consistente.
