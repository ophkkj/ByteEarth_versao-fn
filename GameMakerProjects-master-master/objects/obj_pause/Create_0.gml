/// CREATE — obj_pause (menu de pause animado: ESC ou P)
// O jogo NÃO some: ele só congela (os objetos ignoram o Step enquanto global.pausado for true)
// e a tela fica meio preta com o menu por cima.

depth = -25000;

if (!variable_global_exists("volume")) global.volume = 1;     // 0..1
if (!variable_global_exists("brilho")) global.brilho = 0.5;   // 0..1 (0.5 = normal)
global.pausado = false;
if (!variable_global_exists("inv_aberto")) global.inv_aberto = false;
if (!variable_global_exists("bloqueio_pause")) global.bloqueio_pause = 0;
global.bloqueio_tiro = 0;                                     // evita que o clique no menu vire um tiro
audio_master_gain(global.volume);

pausado = false;
fechando = false;
anim = 0;            // 0..1: abertura / fechamento
tela = 0;            // 0 = principal | 1 = opções | 2 = conquistas | 3 = controles
opcao = 0;
t = 0;
hold = 0;
mx_ant = -1;
my_ant = -1;
arrastando = -1;     // slider que está sendo arrastado com o mouse

principal = ["Continuar", "Opções", "Conquistas", "Controles", "Reiniciar fase", "Menu principal", "Sair do jogo"];
linhas_opcoes = ["Volume", "Brilho", "Efeitos visuais", "Números de dano", "Mira personalizada", "Voltar"];
controles = [
    ["A / D ou setas", "andar"],
    ["W ou seta para cima", "pular"],
    ["Mouse", "mirar e atirar (segure para repetir)"],
    ["SHIFT ou K", "esquiva (luta contra o Paul)"],
    ["1 / 2", "trocar de arma"],
    ["TAB", "inventário e bancada de criação"],
    ["ESC ou P", "pausa"],
    ["F8", "atalho de teste: peças + bancada liberada"]
];

// posição de cada linha do menu (coordenadas da room)
linha_y = function(_i) {
    if (tela == 0) return 232 + _i * 52;
    return 250 + _i * 56;
};
sel_y = linha_y(0);

// partículas flutuando no fundo do menu
n_part = 45;
pp_x = [];
pp_y = [];
pp_v = [];
pp_r = [];
for (var i = 0; i < n_part; i++) {
    pp_x[i] = random(room_width);
    pp_y[i] = random(room_height);
    pp_v[i] = random_range(0.3, 1.2);
    pp_r[i] = random_range(1, 3);
}

// congela tudo: guarda a velocidade de animação e de movimento de cada instância
congelar = function() {
    with (all) {
        if (object_index != obj_pause) {
            _pz_img = image_speed;
            _pz_spd = speed;
            image_speed = 0;
            speed = 0;
        }
    }
    audio_pause_all();
};
descongelar = function() {
    with (all) {
        if (variable_instance_exists(id, "_pz_img")) {
            image_speed = _pz_img;
            speed = _pz_spd;
        }
    }
    audio_resume_all();
};
abrir = function() {
    pausado = true;
    fechando = false;
    global.pausado = true;
    anim = 0;
    tela = 0;
    opcao = 0;
    sel_y = linha_y(0);
    congelar();
};
terminar = function() {
    descongelar();
    pausado = false;
    fechando = false;
    global.pausado = false;
    global.bloqueio_tiro = 8;
    anim = 0;
};
ajustar = function(_i, _delta) {
    if (_i == 0) {
        global.volume = clamp(global.volume + _delta, 0, 1);
        audio_master_gain(global.volume);
    } else if (_i == 1) {
        global.brilho = clamp(global.brilho + _delta, 0, 1);
    }
};
alternar = function(_i) {
    if (_i == 2) global.opt_particulas = !global.opt_particulas;
    if (_i == 3) global.opt_numeros = !global.opt_numeros;
    if (_i == 4) global.opt_mira = !global.opt_mira;
};
