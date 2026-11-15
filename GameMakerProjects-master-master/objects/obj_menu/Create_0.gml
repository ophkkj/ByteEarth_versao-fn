aba_atual = "principal";

opcoes_menu = ["Jogar", "Opções", "Créditos", "Sair"];
espacamento = 40;
hover_index = -1;
timer_alternancia = 0;
delay_troca = 60;
estado_icone = false;
pulsar_velocidade = 0.005;
pulsar_amplitude = 0.1;
icon_padding = 8;
offset_y_icone = 0;

opcao_sel = 0;
volume_jogo = 1.0;
brilho_jogo = 1.0;
audio_master_gain(volume_jogo);

if (!audio_is_playing(snd_musica_menu)) {
    audio_play_sound(snd_musica_menu, 1, true);
}

// ---------- animações do menu ----------
menu_t = 0;
hover_bar = 0;
estrelas = [];
for (var i = 0; i < 70; i++) {
    array_push(estrelas, { x: random(1), y: random(1), v: random_range(0.0004, 0.0016), r: random_range(1, 2.6), a: random_range(0.25, 0.8), f: random(6.28) });
}
cred_scroll = 0;
creditos = [
    "BYTEEARTH", "",
    "Um jogo feito em GameMaker", "",
    "Programação e design", "Davi Oliveira", "Paulo Henrique",
    "Arte dos personagens", "Davi Oliveira", "Paulo Henrique",
    "Cenários e animações", "Luiz Fernando", "Paulo Henrique",
    "Obrigado por jogar!", "",

];
// mantém volume e brilho iguais aos do jogo (o pause usa as mesmas configurações)
if (variable_global_exists("volume")) { volume_jogo = global.volume; audio_master_gain(volume_jogo); }
if (variable_global_exists("brilho")) brilho_jogo = clamp(global.brilho * 2, 0.2, 1.0);
