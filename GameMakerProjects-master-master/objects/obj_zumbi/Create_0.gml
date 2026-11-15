hp = 3;
estado = "vivo";
vsp = 0;
grav = 0.5;
vel = 1.2 * random_range(0.85, 1.25);   // cada zumbi anda num ritmo um pouco diferente
facing = 1;
lado_original = 1; // se ele andar de costas, troque para -1
dano_timer = 0;
morte_timer = 0;
gemido_timer = irandom_range(30, 240); // frames até o próximo gemido
global.tutorial_zumbi_morto = false;

sprite_index = spr_zumbi_idle;
mask_index = spr_zumbi_idle;
image_speed = 0.12;

// mesma altura do David (escala 0.5 dele)
var h_david = sprite_get_bbox_bottom(spr_alien_idle) - sprite_get_bbox_top(spr_alien_idle) + 1;
var h_zumbi = sprite_get_bbox_bottom(spr_zumbi_idle) - sprite_get_bbox_top(spr_zumbi_idle) + 1;
escala = (h_david * 0.5) / h_zumbi;

// CORREÇÃO DO BUG "ZUMBIS PARADOS":
// 1) A escala (e portanto a máscara de colisão) é aplicada JÁ NO CREATE.
//    Antes ela só era aplicada no fim do primeiro Step, e nesse primeiro frame
//    a máscara do zumbi (312x429) ficava gigante e batia nas paredes laterais.
image_xscale = escala;
image_yscale = escala;

// 2) Se nascer dentro de um sólido (ex.: criado exatamente na altura do chão),
//    sobe até sair, em vez de ficar preso para sempre (dentro de um sólido todo
//    teste de movimento dá "bloqueado" e o zumbi nunca mais sai do lugar).
desencravar = function() {
    var _n = 0;
    while (place_meeting(x, y, obj_solido) && _n < 96) { y -= 1; _n++; }
    // Se ainda estiver preso (parede do lado), anda em direção ao centro da room
    var _c = sign((room_width / 2) - x);
    if (_c == 0) _c = 1;
    var _m = 0;
    while (place_meeting(x, y, obj_solido) && _m < 160) { x += _c; _m++; }
    return _n + _m;
};
desencravar();

// 3) Vigia anti-trava (ver Step)
travado_timer = 0;


// Cor do ambiente: nas fases 2 a 5 o personagem recebe um tom frio/escuro parecido com o do cenário
cor_ambiente = c_white;
if (room == rm_fase_2 || room == rm_fase_3 || room == rm_fase_4 || room == rm_fase_5 || room == rm_boss) {
    cor_ambiente = make_colour_rgb(205, 212, 232);
}

// Drop: ao morrer solta 1 peça (e 35% das vezes mais uma). Os tipos vêm de uma "fila" embaralhada,
// então não falta um tipo só por azar: 0 = Engrenagem | 1 = Chip | 2 = Núcleo
soltar_pecas = function() {
    var _n = 1 + ((irandom(99) < 35) ? 1 : 0);
    if (variante == 2) _n += 1;       // o tanque solta mais
    for (var i = 0; i < _n; i++) {
        if (!variable_global_exists("drop_fila") || array_length(global.drop_fila) == 0) {
            global.drop_fila = [0, 1, 2, 0, 1, 2];
            for (var a = array_length(global.drop_fila) - 1; a > 0; a--) {
                var b = irandom(a);
                var tmp = global.drop_fila[a];
                global.drop_fila[a] = global.drop_fila[b];
                global.drop_fila[b] = tmp;
            }
        }
        var _tipo = array_pop(global.drop_fila);
        var _p = instance_create_depth(x + irandom_range(-14, 14), y - 70, 120, obj_peca);
        _p.tipo = _tipo;
        _p.hsp = random_range(-2.2, 2.2);
    }
    // chance de cair um coração (cura 1 vida): 14% (tanque: 40%)
    if (irandom(99) < ((variante == 2) ? 40 : 14)) {
        var _h = instance_create_depth(x, y - 70, 120, obj_peca);
        _h.tipo = 3;
        _h.hsp = random_range(-2.2, 2.2);
    }
};

// ---- variantes: 70% normal | 20% corredor (rápido e frágil) | 10% tanque (grande, lento e resistente) ----
variante = 0;
if (room != rm_fase_1 && room != rm_fase_2) {      // o zumbi do tutorial é sempre normal
    var _rv = irandom(99);
    if (_rv >= 90) variante = 2; else if (_rv >= 70) variante = 1;
}
if (variante == 1) { vel *= 1.6; hp = 2; escala *= 0.93; cor_ambiente = merge_colour(cor_ambiente, make_colour_rgb(255, 225, 120), 0.55); }
if (variante == 2) { vel *= 0.65; hp = 6; escala *= 1.28; cor_ambiente = merge_colour(cor_ambiente, make_colour_rgb(170, 190, 255), 0.55); }
image_xscale = escala;
image_yscale = escala;

// animação: balanço ao correr, "pop" ao levar tiro e aparecer surgindo do chão
t_anim = random(100);
pop = 0;
spawn_t = 20;
if (instance_exists(obj_fx)) {
    obj_fx.poeira(x, y, -1);
    obj_fx.poeira(x, y, 1);
    obj_fx.faisca(x, y - 40, make_colour_rgb(140, 255, 90), 8, 3);
}
