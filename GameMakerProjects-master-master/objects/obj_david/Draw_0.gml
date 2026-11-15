/// DRAW — obj_david

// Todas as animações do David (spr_david_*) usam a mesma tela (192x224) e a mesma
// origem (centro dos pés), então não precisa mais de ajuste vertical por animação.

// Pisca enquanto está invencível
var alpha = alfa_david;
if (invencivel && (tempo_invencivel div 4) mod 2 == 0) alpha = 0.3 * alfa_david;

// Sombra no chão (só nas fases 2 a 5, onde há cenário de cidade/metrô)
if (cor_ambiente != c_white) {
    var _gy = y;
    var _n = 0;
    while (!place_meeting(x, _gy + 1, obj_solido) && _n < 400) { _gy += 1; _n++; }
    var _enc = clamp((_gy - y) / 220, 0, 0.6);   // quanto mais alto, menor e mais fraca
    var _w = 26 * (1 - _enc);
    draw_set_alpha(0.38 * (1 - _enc) * alfa_david);
    draw_ellipse_color(x - _w, _gy - 5, x + _w, _gy + 2, c_black, c_black, false);
    draw_set_alpha(1);
}

if (dash_t > 0) {
    alpha = 0.6 * alfa_david;
    // rastro da esquiva
    for (var _g = 1; _g <= 3; _g++) {
        draw_sprite_ext(sprite_index, image_index, x - dash_dir * _g * (dash_vel * 1.2), y, escala_idle * direcao, escala_idle, 0, make_colour_rgb(120, 220, 255), 0.4 / _g);
    }
}

// amassa/estica (pouso, pulo, tiro, dano) em torno dos pés
var _sx = escala_idle * direcao * (1 + squash * 0.6);
var _sy = escala_idle * (1 - squash * 0.6);

// ao morrer: cai para trás e vai sumindo
var _ang = 0;
if (morrendo) {
    var _pm = 1 - clamp(tempo_morte / 60, 0, 1);
    _ang = -direcao * _pm * 80;
    alpha = alfa_david * (1 - clamp((_pm - 0.45) * 2, 0, 1));
}

draw_sprite_ext(sprite_index, image_index, x, y, _sx, _sy, _ang, cor_ambiente, alpha);
