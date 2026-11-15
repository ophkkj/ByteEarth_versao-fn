/// STEP — obj_peca
if (variable_global_exists("pausado") && global.pausado) exit;

t++;

// o coração some se ninguém pegar
if (tipo == 3 && t > 900) {
    if (instance_exists(obj_fx)) obj_fx.faisca(x, y, make_colour_rgb(255, 90, 120), 6, 2);
    instance_destroy();
    exit;
}

// cai e quica uma vez no chão
if (estado == "caindo") {
    vsp += grav;
    if (!place_meeting(x + hsp, y, obj_solido)) x += hsp; else hsp = -hsp * 0.5;
    if (place_meeting(x, y + vsp, obj_solido)) {
        var _s = sign(vsp);
        var _n = 0;
        while (_s != 0 && !place_meeting(x, y + _s, obj_solido) && _n < 30) { y += _s; _n++; }
        if (vsp > 2) {
            vsp = -vsp * 0.35;
            hsp *= 0.6;
            if (instance_exists(obj_fx)) obj_fx.poeira(x, y + 12, 1);
        } else {
            vsp = 0;
            hsp = 0;
            estado = "parada";
        }
    } else {
        y += vsp;
    }
}

// o David chega perto: o item é puxado até ele
if (instance_exists(obj_david) && t > 20) {
    var _d = instance_find(obj_david, 0);
    var _dist = point_distance(x, y, _d.x, _d.y - 40);
    var _quer = (tipo != 3) || (_d.vida < _d.vida_max);       // coração só é puxado se estiver faltando vida
    if (estado == "parada" && _dist < 150 && _quer) { imanta = true; estado = "voando"; }
    if (imanta) {
        var _dir = point_direction(x, y, _d.x, _d.y - 40);
        var _v = clamp(300 / max(_dist, 1), 3, 12);
        x += lengthdir_x(_v, _dir);
        y += lengthdir_y(_v, _dir);
        if (instance_exists(obj_fx) && t mod 3 == 0) obj_fx.faisca(x, y, (tipo == 3) ? make_colour_rgb(255, 90, 120) : make_colour_rgb(120, 230, 255), 1, 1);
    }
    if (_dist < 34 && _quer) {
        var _snd = audio_play_sound(snd_david_pulo, 1, false);
        if (tipo == 3) {
            with (_d) curar();
            audio_sound_pitch(_snd, 1.6);
        } else {
            global.inv[tipo] += 1;
            global.st_pecas += 1;
            audio_sound_pitch(_snd, 2.2 + tipo * 0.2);
            with (obj_inventario) novo_popup("+1 " + nomes[other.tipo], other.x, other.y - 20, cores[other.tipo]);
        }
        if (instance_exists(obj_fx)) {
            obj_fx.faisca(x, y, (tipo == 3) ? make_colour_rgb(255, 90, 120) : make_colour_rgb(120, 230, 255), 10, 3);
            obj_fx.anel(x, y, (tipo == 3) ? make_colour_rgb(255, 90, 120) : make_colour_rgb(120, 230, 255), 36, 14);
        }
        instance_destroy();
    }
}
