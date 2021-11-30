//------------------------------Laboratorio Digital II---------------------------------
// Projeto: QuietWatch (T3BB5)
// Gabriel Pereira de Carvalho
// Otávio Felipe de Freitas
// Willian Abe Fukushima
//-------------------------------------------------------------------------------------
// Para interagir com interface, são utilizados comandos de teclado (PUBLISH)
// l = entrada ligar
// r = entrada reset
// m = entrada mode
// x = entrada sel_mux[0]
// y = entrada sel_mux[1]
//-------------------------------------------------------------------------------------

//Bibliotecas Java
import java.io.IOException;
import java.time.format.DateTimeFormatter;  
import java.time.LocalDateTime;
//Bibliotecas Processing
import mqtt.*;
import ddf.minim.*;

//--------------------------------- Conexão MQTT --------------------------------------
String user   = "grupo1-bancadaB5";
String passwd = "L%40Bdygy1B5";      // manter %40
String broker = "3.141.193.238";     
String port   = "80";
MQTTClient client;
String clientID;
//-------------------------------------------------------------------------------------

//------------------------------------ Variaveis --------------------------------------
int whichKey = -1;  // variavel mantem tecla acionada
Boolean estado_ligar = false;
Boolean estado_mode = false;
Boolean estado_reset = false;
Boolean estado_selmux0 = false;
Boolean estado_selmux1 = false;
Boolean estado_alerta = false;
Boolean estado_calibrando = false;
PFont myFont;
int largura = 960;
int altura = 600;
PrintWriter QuietWatch_logger;
Minim minim;
AudioPlayer som_calibrando, som_alarme;
//-------------------------------------------------------------------------------------

//----------------------------- Setup: executado uma vez ------------------------------
void setup() {
  // Tamanho do quadro
  size(960, 600);
  myFont = loadFont("myfont.vlw");
  smooth();
  //setup PrintWriter
  QuietWatch_logger = createWriter("QuietWatch_logs_" + day() + "_" + month() + "_" + year() + "_horario_" + hour() + "_" + minute() + "_" + second() + ".txt");
  QuietWatch_logger.println("Setup Processing " + day() + "/" + month() + "/" + year() + " horario " + hour() + ":" + minute() + ":" + second());
  QuietWatch_logger.flush();
  // setup Minim
  minim = new Minim(this);
  som_calibrando = minim.loadFile("som_calibrando.mp3");
  som_alarme = minim.loadFile("som_alarme.mp3");
  // Conectar com MQTT
  client = new MQTTClient(this);
  clientID = new String("labead-mqtt-processing-" + random(0,100));
  println("clientID=" + clientID);
  client.connect("mqtt://" + user + ":" + passwd + "@" + broker + ":" + port, clientID, false);
  // Garantir sinais zerados
  client.publish(user + "/E0", "0");
  client.publish(user + "/E1", "0");
  client.publish(user + "/E2", "0");
  client.publish(user + "/E3", "0");
  client.publish(user + "/E4", "0");
}
//-------------------------------------------------------------------------------------

//--------------------------- Draw: executado continuamente ---------------------------
void draw() { 
    cursor(HAND);
    textFont(myFont);
    background(#B6BCB3);    
    // chama funcoes para desenhar painel do sistema de segurança
    drawCabecalho();
    drawQuadro();
}
//-------------------------------------------------------------------------------------


void drawCabecalho() {
    textAlign(CENTER);
    textSize(30);
    fill(0);
    text("Controle os Widgets com o teclado", 10, 10, largura, altura);
    textAlign(CENTER);
    textSize(15);
    fill(0);
    text("r : E0 (reset)", 10, 40, largura, altura);
    textAlign(CENTER);
    textSize(15);
    fill(0);
    text("l: E1 (ligar)", 10, 55, largura, altura);
    textAlign(CENTER);
    textSize(15);
    fill(0);
    text("x,y: E2,E3 (sel_mux)", 10, 70, largura, altura);
    textAlign(CENTER);
    textSize(15);
    fill(0);
    text("m: E4 (modo 0 'em casa' ou 1 'fora de casa')", 10, 85, largura, altura);
    
}
void drawQuadro(){
  stroke(#300A8B);
  fill(#868489);
  rect(250, 100, 500, 410);
//------------------------------- Widgets para Inputs --------------------------------
  if(estado_ligar){//l de ligar
    fill(#FF0303);
    ellipse(350, 150, 70, 70);
    textSize(12);
    fill(0);
    text("on", 350, 155);
  }else{
    fill(#B6BCB3);
    ellipse(350, 150, 70, 70);
    textSize(12);
    fill(0);
    text("off", 350, 155);
  }
  if(estado_mode){// m de mode
    fill(#FF0303);
    ellipse(350, 250, 70, 70);
    textSize(11);
    fill(0);
    text("Fora de Casa", 350, 255);
  }else{
    fill(#B6BCB3);
    ellipse(350, 250, 70, 70);
    textSize(12);
    fill(0);
    text("Em Casa", 350, 255);
  }
  if(estado_reset){// r de reset
    fill(#FF0303);
    ellipse(350, 350, 70, 70);
    textSize(12);
    fill(0);
    text("reset", 350, 355);
  }else{
    fill(#B6BCB3);
    ellipse(350, 350, 70, 70);
    textSize(12);
    fill(0);
    text("reset", 350, 355);
  }
  if(estado_selmux0){//x de sel_mux[0] (E2)
    fill(#FF0303);
    ellipse(300, 450, 70, 70);
    textSize(12);
    fill(0);
    text("sel_mux[0]", 300, 455);
  }else{
    fill(#B6BCB3);
    ellipse(300, 450, 70, 70);
    textSize(12);
    fill(0);
    text("sel_mux[0]", 300, 455);
  }
  if(estado_selmux1){//y de sel_mux[1] (E3)
    fill(#FF0303);
    ellipse(400, 450, 70, 70);
    textSize(12);
    fill(0);
    text("sel_mux[1]", 400, 455);
  }else{
    fill(#B6BCB3);
    ellipse(400, 450, 70, 70);
    textSize(12);
    fill(0);
    text("sel_mux[1]", 400, 455);
  }
  //-----------------------------------------------------------------------------------
  stroke(255,0,0);
  strokeWeight(5);
  line(500,100,500,510);
  //------------------------------ Widgets para Outputs -------------------------------
  if(estado_alerta){
    stroke(#300A8B);
    fill(#FF0303);
    ellipse(600, 150, 70, 70);
    textSize(12);
    fill(0);
    text("alerta on", 600, 155);
    if(estado_mode){//alarme eh tocado apenas no modo fora de casa
      som_alarme.play();
    }
  }else{
    stroke(#300A8B);
    fill(#B6BCB3);
    ellipse(600, 150, 70, 70);
    textSize(12);
    fill(0);
    text("alerta off", 600, 155);
    som_alarme.pause();
  }
  if(estado_calibrando){
    stroke(#300A8B);
    fill(#FF0303);
    ellipse(600, 250, 70, 70);
    textSize(12);
    fill(0);
    text("calibrando...", 600, 255);
    som_calibrando.play();
  }else{
    stroke(#300A8B);
    if(estado_ligar){
      fill(#00FF12);
      ellipse(600, 250, 70, 70);
      textSize(12);
      fill(0);
      text("calibrado", 600, 255);
    }else{
      fill(#B6BCB3);
      ellipse(600, 250, 70, 70);
    }
    som_calibrando.pause();
  }
  //-------------------------------------------------------------------------------------
  String dispTime = "Hora: " + hour() + ":" + minute() + ":" + second();
  fill(0);
  rect(605, 485, 85, 20);
  fill(#B6BCB3);
  text(dispTime, 650, 500);
}

//---------------------- keyPressed: processa entrada por teclado ---------------------
// funcao keyPressed - processa tecla acionada
void keyPressed() {
  whichKey = key;
  if(whichKey == 114){
    estado_reset = !estado_reset;
    if(estado_reset){
      client.publish(user + "/E0", "1");
      QuietWatch_logger.println("Reset  " + hour() + ":" + minute() + ":" + second());
      QuietWatch_logger.flush();
    }else{
      client.publish(user + "/E0", "0");
    }
  }
  if(whichKey == 108){
    estado_ligar = !estado_ligar;
    if(estado_ligar){
      client.publish(user + "/E1", "1");
      QuietWatch_logger.println("Ligar  " + hour() + ":" + minute() + ":" + second());
      QuietWatch_logger.flush();
    }else{
      client.publish(user + "/E1", "0");
    }
  }
  if(whichKey == 120){
    estado_selmux0 = !estado_selmux0;
    if(estado_selmux0){
      client.publish(user + "/E2", "1");
    }else{
      client.publish(user + "/E2", "0");
    }
  }
  if(whichKey == 121){
    estado_selmux1 = !estado_selmux1;
    if(estado_selmux1){
      client.publish(user + "/E3", "1");
    }else{
      client.publish(user + "/E3", "0");
    }
  }
  if(whichKey == 109){
    estado_mode = !estado_mode;
    if(estado_mode){
      client.publish(user + "/E4", "1");
      QuietWatch_logger.println("Modo Fora de Casa  " + hour() + ":" + minute() + ":" + second());
      QuietWatch_logger.flush();
    }else{
      client.publish(user + "/E4", "0");
      QuietWatch_logger.println("Modo Em Casa  " + hour() + ":" + minute() + ":" + second());
      QuietWatch_logger.flush();
    }
  }
}
//-------------------------------------------------------------------------------------

//--------------------------------- Funções para MQTT ---------------------------------
void clientConnected() {
  println("cliente conectado");
  client.subscribe(user + "/E0");
  client.subscribe(user + "/E1");
  client.subscribe(user + "/E2");
  client.subscribe(user + "/E3");
  client.subscribe(user + "/E4");
  client.subscribe(user + "/S0");//alerta movimento
  client.subscribe(user + "/S1");//calibrando
}

void messageReceived(String topic, byte[] payload) {
  String dados = new String(payload);
  
  if(topic.endsWith("E0")){
    if(Integer.parseInt(dados) == 1){
      estado_reset = true;
    }else{
      estado_reset = false;
    }
  }
  
  if(topic.endsWith("E1")){
    if(Integer.parseInt(dados) == 1){
      estado_ligar = true;
    }else{
      estado_ligar = false;
    }
  }
  
  if(topic.endsWith("E2")){
    if(Integer.parseInt(dados) == 1){
      estado_selmux0 = true;
    }else{
      estado_selmux0 = false;
    }
  }
  
  if(topic.endsWith("E3")){
    if(Integer.parseInt(dados) == 1){
      estado_selmux1 = true;
    }else{
      estado_selmux1 = false;
    }
  }
  
  if(topic.endsWith("E4")){
    if(Integer.parseInt(dados) == 1){
      estado_mode = true;
    }else{
      estado_mode = false;
    }
  }
  
  if(topic.endsWith("S0")){//mensagem veio de S0 (alerta_mov)
    if(Integer.parseInt(dados) == 1){//alerta esta ativado
      estado_alerta = true;
      DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");  
      LocalDateTime now = LocalDateTime.now(); 
      println("ALERTA DE MOVIMENTO : " + dtf.format(now));
      // persistir mensagem de evento "ALERTA DE MOVIMENTO"
      QuietWatch_logger.println("ALERTA DE MOVIMENTO  " + hour() + ":" + minute() + ":" + second());
      QuietWatch_logger.flush();
    }
  }
  
  if(topic.endsWith("S1")){//mensagem veio de S1 (calibrando)
    if(Integer.parseInt(dados) == 1){//alerta esta ativado
      estado_calibrando = true;
      DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");  
      LocalDateTime now = LocalDateTime.now(); 
      println("Calibrando : " + dtf.format(now));
      // persistir mensagem de evento "Calibrando"
      QuietWatch_logger.println("Calibrando  " + hour() + ":" + minute() + ":" + second());
      QuietWatch_logger.flush();
    }else{
      estado_calibrando = false;
    }
  }
}
void connectionLost() {
  println("conexao perdida");
}
//-----------------------------------------------------------------------------------
