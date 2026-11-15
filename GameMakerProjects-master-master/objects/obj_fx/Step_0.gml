/// STEP — obj_fx

// durante o pause/inventário tudo congela e o cursor volta ao normal
if (variable_global_exists("pausado") && global.pausado) {
    window_set_cursor(cr_default);
    exit;
}

t++;

// ---- partículas ----
for (var i = array_length(parts) - 1; i >= 0; i--) {
    var _p = parts[i];
    _p.x += _p.vx;
    _p.y += _p.vy;
    _p.vy += _p.g;
    _p.vx *= 0.97;
    _p.vida--;
    if (_p.vida <= 0) array_delete(parts, i, 1);
}
for (var i = array_length(aneis) - 1; i >= 0; i--) {
    aneis[i].t++;
    if (aneis[i].t >= aneis[i].dur) array_delete(aneis, i, 1);
}
for (var i = array_length(nums) - 1; i >= 0; i--) {
    var _n = nums[i];
    _n.t++;
    _n.y -= 0.9 * (1 - _n.t / 70);
    _n.x += _n.dx;
    if (_n.t > 70) array_delete(nums, i, 1);
}
if (flash_a > 0) flash_a = max(0, flash_a - 0.03);
if (titulo_t > 0) titulo_t--;
mira_k = lerp(mira_k, 0, 0.18);
if (combo_pulso > 0) combo_pulso--;

// ---- combo: some se ficar um tempo sem abater ninguém ----
if (global.combo_t > 0) {
    global.combo_t--;
    if (global.combo_t <= 0) global.combo = 0;
}
if (global.combo > global.combo_max) {
    global.combo_max = global.combo;
    combo_pulso = 18;
}

// ---- conquistas ----
if (t mod 15 == 0) {
    var _ok = [
        global.st_abates >= 1, global.st_abates >= 15, global.st_abates >= 40, global.st_pecas >= 10, global.combo_max >= 5,
        global.st_esquivas >= 10, global.canhao_criado, global.jogos_concluidos, global.boss_vencido
    ];
    for (var c = 0; c < array_length(_ok); c++) {
        if (_ok[c] && !global.conq[c]) {
            global.conq[c] = true;
            aviso(global.conq_def[c].nome, global.conq_def[c].desc);
        }
    }
}
if (toast_t > 0) {
    toast_t--;
} else if (array_length(toasts) > 0) {
    toast_atual = toasts[0];
    array_delete(toasts, 0, 1);
    toast_t = 260;
    var _sd = audio_play_sound(snd_david_pulo, 1, false);
    audio_sound_pitch(_sd, 2.0);
}

// ---- cursor: some quando a mira personalizada está aparecendo ----
var _dav = instance_exists(obj_david) ? instance_find(obj_david, 0) : noone;
mira_visivel = global.opt_mira && _dav != noone && !_dav.controle_travado && !_dav.morrendo;
window_set_cursor(mira_visivel ? cr_none : cr_default);

// ---- cura: o coração que cai some depois de um tempo (ver obj_peca) ----
