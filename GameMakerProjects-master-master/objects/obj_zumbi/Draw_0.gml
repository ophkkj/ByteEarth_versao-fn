/// DRAW — obj_zumbi

// Sombra no chão (fases 2 a 5)
if (cor_ambiente != c_white) {
    var _gy = y;
    var _n = 0;
    while (!place_meeting(x, _gy + 1, obj_solido) && _n < 400) { _gy += 1; _n++; }
    var _enc = clamp((_gy - y) / 220, 0, 0.6);
    var _w = 24 * (1 - _enc);
    draw_set_alpha(0.38 * (1 - _enc) * image_alpha);
    draw_ellipse_color(x - _w, _gy - 5, x + _w, _gy + 2, c_black, c_black, false);
    draw_set_alpha(1);
}

// balanço ao correr, "pop" ao levar tiro e surgindo do chão
var _viva = (estado == "vivo");
var _bob = _viva ? -abs(sin(t_anim * 0.16)) * 3 : 0;
var _tilt = _viva ? sin(t_anim * 0.16) * 3 : 0;
var _sp = 1 - spawn_t / 20;
var _ex = image_xscale * (1 + pop * 0.25) * (0.6 + 0.4 * _sp);
var _ey = image_yscale * (1 - pop * 0.25) * (0.6 + 0.4 * _sp);
draw_sprite_ext(sprite_index, image_index, x, y + _bob, _ex, _ey, _tilt, image_blend, image_alpha * _sp);
