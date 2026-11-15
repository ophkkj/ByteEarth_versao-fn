/// DRAW — obj_peca
var _bob = (estado == "parada") ? sin((t + tipo * 20) * 0.08) * 3 : 0;

if (estado == "parada") {
    draw_set_alpha(0.35);
    draw_ellipse_color(x - 12, y + 14, x + 12, y + 20, c_black, c_black, false);
    draw_set_alpha(1);
}

// brilho suave na cor do item
var _cg = make_colour_rgb(55, 65, 90);
if (tipo == 1) _cg = make_colour_rgb(25, 85, 40);
if (tipo == 2) _cg = make_colour_rgb(20, 95, 125);
if (tipo == 3) _cg = make_colour_rgb(110, 25, 45);
gpu_set_blendmode(bm_add);
draw_circle_color(x, y + _bob, 26, _cg, c_black, false);
gpu_set_blendmode(bm_normal);

// o coração pisca quando está para sumir
var _alfa = 1;
if (tipo == 3 && t > 700 && (t div 6) mod 2 == 0) _alfa = 0.35;
var _pulso = (tipo == 3) ? 1 + 0.08 * sin(t * 0.2) : 1;
draw_sprite_ext(spr_peca, tipo, x, y + _bob, image_xscale * _pulso, image_yscale * _pulso, 0, c_white, _alfa);
