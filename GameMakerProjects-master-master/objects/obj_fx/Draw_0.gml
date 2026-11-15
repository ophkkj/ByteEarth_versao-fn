/// DRAW — obj_fx

var _W = room_width;
var _H = room_height;
var _dav = instance_exists(obj_david) ? instance_find(obj_david, 0) : noone;

// ---------------- anéis de choque ----------------
gpu_set_blendmode(bm_add);
for (var i = 0; i < array_length(aneis); i++) {
    var _a = aneis[i];
    var _k = _a.t / _a.dur;
    var _r = _a.rmax * (1 - power(1 - _k, 3));
    draw_set_alpha(1 - _k);
    draw_circle_color(_a.x, _a.y, _r, _a.cor, _a.cor, true);
    draw_circle_color(_a.x, _a.y, max(0, _r - 2), _a.cor, _a.cor, true);
    draw_circle_color(_a.x, _a.y, max(0, _r - 4), _a.cor, _a.cor, true);
}
// partículas brilhantes
for (var i = 0; i < array_length(parts); i++) {
    var _p = parts[i];
    if (!_p.add) continue;
    var _k = _p.vida / _p.vmax;
    draw_set_alpha(_k);
    draw_circle_color(_p.x, _p.y, lerp(_p.r1, _p.r0, _k), _p.cor, _p.cor, false);
}
gpu_set_blendmode(bm_normal);
// partículas normais (poeira)
for (var i = 0; i < array_length(parts); i++) {
    var _p = parts[i];
    if (_p.add) continue;
    var _k = _p.vida / _p.vmax;
    draw_set_alpha(_k * 0.55);
    draw_circle_color(_p.x, _p.y, lerp(_p.r1, _p.r0, _k), _p.cor, _p.cor, false);
}
draw_set_alpha(1);

// ---------------- números de dano ----------------
draw_set_font(fMenu);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
for (var i = 0; i < array_length(nums); i++) {
    var _n = nums[i];
    var _esc = (_n.grande ? 1.0 : 0.7) * (1 + max(0, 1 - _n.t / 8) * 0.6);
    draw_set_alpha(clamp((70 - _n.t) / 22, 0, 1));
    draw_set_color(c_black);
    draw_text_transformed(_n.x + 2, _n.y + 2, _n.txt, _esc, _esc, 0);
    draw_set_color(_n.cor);
    draw_text_transformed(_n.x, _n.y, _n.txt, _esc, _esc, 0);
}
draw_set_alpha(1);

// ---------------- aviso de vida baixa: bordas vermelhas pulsando ----------------
if (_dav != noone && global.opt_particulas && _dav.vida == 1 && !_dav.morrendo) {
    var _pulso = 0.5 + 0.5 * sin(t * 0.13);
    draw_set_color(make_colour_rgb(200, 0, 20));
    for (var s = 0; s < 8; s++) {
        draw_set_alpha((0.05 + 0.14 * _pulso) * (1 - s / 8));
        draw_rectangle(0, s * 14, _W, s * 14 + 14, false);
        draw_rectangle(0, _H - s * 14 - 14, _W, _H - s * 14, false);
        draw_rectangle(s * 14, 0, s * 14 + 14, _H, false);
        draw_rectangle(_W - s * 14 - 14, 0, _W - s * 14, _H, false);
    }
    draw_set_alpha(1);
}

// ---------------- clarão de tela ----------------
if (flash_a > 0) {
    draw_set_alpha(flash_a);
    draw_set_color(flash_cor);
    draw_rectangle(0, 0, _W, _H, false);
    draw_set_alpha(1);
}

// ---------------- combo ----------------
if (_dav != noone && !_dav.controle_travado && global.combo >= 2) {
    var _cs = 1 + combo_pulso * 0.03;
    var _cf = clamp(global.combo_t / 40, 0, 1);
    draw_set_halign(fa_left);
    draw_set_alpha(_cf);
    draw_set_color(c_black);
    draw_text_transformed(32, 142, "COMBO x" + string(global.combo), _cs * 1.0, _cs * 1.0, 0);
    draw_set_color(make_colour_rgb(255, 220, 80));
    draw_text_transformed(30, 140, "COMBO x" + string(global.combo), _cs * 1.0, _cs * 1.0, 0);
    draw_set_color(make_colour_rgb(30, 34, 50));
    draw_rectangle(30, 164, 30 + 120, 170, false);
    draw_set_color(make_colour_rgb(255, 220, 80));
    draw_rectangle(30, 164, 30 + 120 * clamp(global.combo_t / 180, 0, 1), 170, false);
    draw_set_alpha(1);
}

// ---------------- cartão de título da fase ----------------
if (titulo_t > 0) {
    var _p2 = 1 - titulo_t / titulo_dur;
    var _al = (_p2 < 0.12) ? _p2 / 0.12 : ((_p2 > 0.8) ? (1 - _p2) / 0.2 : 1);
    var _sl = 1 - power(1 - clamp(_p2 * 3.5, 0, 1), 3);
    var _tx = 90 + (1 - _sl) * -420;
    draw_set_alpha(0.55 * _al);
    draw_set_color(c_black);
    draw_rectangle(0, 214, _W, 322, false);
    draw_set_alpha(_al);
    draw_set_color(make_colour_rgb(70, 220, 255));
    draw_rectangle(0, 214, _W * _sl, 217, false);
    draw_rectangle(0, 319, _W * _sl, 322, false);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_color(c_black);
    draw_text_transformed(_tx + 3, 252 + 3, titulo_txt, 2.2, 2.2, 0);
    draw_set_color(make_colour_rgb(120, 230, 90));
    draw_text_transformed(_tx, 252, titulo_txt, 2.2, 2.2, 0);
    draw_set_color(c_white);
    draw_text_transformed(_tx + 8, 298, titulo_sub, 0.8, 0.8, 0);
    draw_set_alpha(1);
}

// ---------------- aviso de conquista ----------------
if (toast_t > 0 && !is_undefined(toast_atual)) {
    var _pt = 1 - toast_t / 260;
    var _ent = 1 - power(1 - clamp(_pt * 6, 0, 1), 3);
    var _sai = clamp((toast_t) / 25, 0, 1);
    var _ty = _H + 10 - 110 * _ent * _sai;
    draw_set_alpha(0.85 * _sai);
    draw_set_color(make_colour_rgb(8, 12, 26));
    draw_rectangle(_W / 2 - 250, _ty, _W / 2 + 250, _ty + 84, false);
    draw_set_alpha(_sai);
    draw_set_color(make_colour_rgb(255, 210, 70));
    draw_rectangle(_W / 2 - 250, _ty, _W / 2 + 250, _ty + 84, true);
    draw_rectangle(_W / 2 - 250, _ty, _W / 2 - 242, _ty + 84, false);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text_transformed(_W / 2 - 226, _ty + 16, "CONQUISTA DESBLOQUEADA", 0.5, 0.5, 0);
    draw_set_color(c_white);
    draw_text_transformed(_W / 2 - 226, _ty + 42, toast_atual.nome, 0.95, 0.95, 0);
    draw_set_color(make_colour_rgb(170, 175, 190));
    draw_text_transformed(_W / 2 - 226, _ty + 68, toast_atual.desc, 0.5, 0.5, 0);
    draw_set_alpha(1);
}

// ---------------- mira personalizada ----------------
if (mira_visivel && !global.pausado) {
    var _mx = mouse_x;
    var _my = mouse_y;
    var _canh = (global.arma_atual == 1);
    var _cor = _canh ? make_colour_rgb(255, 150, 60) : make_colour_rgb(120, 230, 255);
    var _pronto = _canh ? (_dav.tempo_canhao <= 0) : true;
    var _r = 11 + 14 * mira_k;
    draw_set_alpha(_pronto ? 0.95 : 0.4);
    draw_circle_color(_mx, _my, _r, _cor, _cor, true);
    draw_circle_color(_mx, _my, _r - 1, _cor, _cor, true);
    for (var q = 0; q < 4; q++) {
        var _ang = t * 2 + q * 90;
        draw_line_width_color(_mx + lengthdir_x(_r + 2, _ang), _my + lengthdir_y(_r + 2, _ang), _mx + lengthdir_x(_r + 10, _ang), _my + lengthdir_y(_r + 10, _ang), 2, _cor, _cor);
    }
    draw_circle_color(_mx, _my, 2, _cor, _cor, false);
    draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
