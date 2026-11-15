if (estado == "vivo") {
    var _dano = other.dano;                 // pistola = 1 | canhão = 10
    var _esc = other.escala_impacto;
    hp -= _dano;
    dano_timer = 12;
    var _im = instance_create_depth(other.x, other.y, -10002, obj_bala_impacto);
    _im.image_xscale = _esc;
    _im.image_yscale = _esc;
    pop = 0.3;
    if (instance_exists(obj_fx)) {
        obj_fx.faisca(other.x, other.y, make_colour_rgb(140, 255, 90), (_dano >= 5) ? 14 : 6, (_dano >= 5) ? 5 : 3);
        obj_fx.numero(x + irandom_range(-14, 14), y - 130, "-" + string(_dano), (_dano >= 5) ? make_colour_rgb(255, 170, 70) : c_white, _dano >= 5);
    }
    with (other) instance_destroy();
}