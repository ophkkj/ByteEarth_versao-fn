/// CREATE — obj_fx: efeitos visuais globais (partículas, anéis, números de dano, mira, títulos, conquistas)

depth = -23000;

// ---- opções (ficam no menu de pause > Opções) ----
if (!variable_global_exists("opt_particulas")) global.opt_particulas = true;   // partículas, anéis e clarões
if (!variable_global_exists("opt_numeros")) global.opt_numeros = true;         // números de dano
if (!variable_global_exists("opt_mira")) global.opt_mira = true;               // mira personalizada

// ---- estatísticas e conquistas ----
if (!variable_global_exists("st_abates")) {
    global.st_abates = 0; global.st_pecas = 0; global.st_tiros = 0; global.st_esquivas = 0; global.st_mortes = 0;
    global.combo = 0; global.combo_t = 0; global.combo_max = 0; global.boss_vencido = false;
    global.conq = [false, false, false, false, false, false, false, false, false];
}
if (room == rm_fase_1) {          // partida nova
    global.st_abates = 0; global.st_pecas = 0; global.st_tiros = 0; global.st_esquivas = 0; global.st_mortes = 0;
    global.combo = 0; global.combo_t = 0; global.combo_max = 0; global.boss_vencido = false;
    global.conq = [false, false, false, false, false, false, false, false, false];
}
global.conq_def = [
    { nome: "Primeiro Sangue", desc: "Derrote um zumbi." },
    { nome: "Caçador", desc: "Derrote 15 zumbis." },
    { nome: "Exterminador", desc: "Derrote 40 zumbis." },
    { nome: "Colecionador", desc: "Colete 10 peças." },
    { nome: "Combo x5", desc: "Derrote 5 zumbis em sequência." },
    { nome: "Pé de Vento", desc: "Use a esquiva 10 vezes." },
    { nome: "Engenheiro", desc: "Crie o Canhão de Plasma." },
    { nome: "Mente Brilhante", desc: "Conclua os 3 jogos do computador." },
    { nome: "Irmão Derrotado", desc: "Derrote o Paul." }
];

parts = [];        // partículas
aneis = [];        // anéis de choque
nums = [];         // números de dano
toasts = [];       // fila de avisos de conquista
toast_t = 0;
toast_atual = undefined;
t = 0;
mira_k = 0;        // "coice" da mira ao atirar
flash_cor = c_white;
flash_a = 0;
titulo_txt = "";
titulo_sub = "";
titulo_t = 0;
titulo_dur = 170;
combo_pulso = 0;
mira_visivel = false;

// ---------------- métodos que o resto do jogo chama ----------------
faisca = function(_x, _y, _cor, _n, _vel) {
    if (!global.opt_particulas) return;
    for (var i = 0; i < _n; i++) {
        if (array_length(parts) > 450) return;
        var _a = random(360);
        var _v = random_range(0.4, 1) * _vel;
        var _vd = irandom_range(18, 36);
        array_push(parts, { x: _x, y: _y, vx: lengthdir_x(_v, _a), vy: lengthdir_y(_v, _a) - 0.5, g: 0.12, vida: _vd, vmax: _vd, r0: random_range(2.5, 4.5), r1: 0.5, cor: _cor, add: true });
    }
};
poeira = function(_x, _y, _dir) {
    if (!global.opt_particulas) return;
    for (var i = 0; i < 6; i++) {
        if (array_length(parts) > 450) return;
        var _vd = irandom_range(18, 30);
        array_push(parts, { x: _x + random_range(-8, 8), y: _y - 2, vx: _dir * random_range(0.3, 1.6) + random_range(-0.4, 0.4), vy: random_range(-1.1, -0.2), g: -0.01, vida: _vd, vmax: _vd, r0: random_range(2, 4), r1: random_range(7, 11), cor: make_colour_rgb(170, 160, 150), add: false });
    }
};
atrair = function(_cx, _cy, _cor, _n, _raio) {      // partículas que correm para um ponto (carga de ataque)
    if (!global.opt_particulas) return;
    for (var i = 0; i < _n; i++) {
        if (array_length(parts) > 450) return;
        var _a = random(360);
        var _sx = _cx + lengthdir_x(_raio, _a);
        var _sy = _cy + lengthdir_y(_raio, _a);
        array_push(parts, { x: _sx, y: _sy, vx: (_cx - _sx) / 20, vy: (_cy - _sy) / 20, g: 0, vida: 20, vmax: 20, r0: 3.5, r1: 1, cor: _cor, add: true });
    }
};
anel = function(_x, _y, _cor, _rmax, _dur) {
    if (!global.opt_particulas) return;
    array_push(aneis, { x: _x, y: _y, cor: _cor, rmax: _rmax, dur: _dur, t: 0 });
};
numero = function(_x, _y, _txt, _cor, _grande) {
    if (!global.opt_numeros) return;
    array_push(nums, { x: _x, y: _y, txt: _txt, cor: _cor, grande: _grande, t: 0, dx: random_range(-0.4, 0.4) });
};
brilho_tela = function(_cor, _a) {
    if (!global.opt_particulas) return;
    flash_cor = _cor;
    flash_a = max(flash_a, _a);
};
titulo = function(_txt, _sub) {
    titulo_txt = _txt;
    titulo_sub = _sub;
    titulo_t = titulo_dur;
};
aviso = function(_nome, _desc) {
    array_push(toasts, { nome: _nome, desc: _desc });
};

// cartão de título ao entrar em cada fase
if (room == rm_fase_1) titulo("FASE 1", "Primeiros passos");
else if (room == rm_fase_2) titulo("FASE 2", "Ruas desertas");
else if (room == rm_fase_3) titulo("FASE 3", "A entrada do metrô");
else if (room == rm_fase_4) titulo("FASE 4", "Plataforma abandonada");
else if (room == rm_fase_5) titulo("FASE 5", "O computador central");
