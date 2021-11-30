//--------------------------Laboratorio Digital II-----------------------------
// Projeto: QuietWatch (T3BB5)
// Gabriel Pereira de Carvalho
// Otávio Felipe de Freitas
// Willian Abe Fukushima
//-----------------------------------------------------------------------------
// Para interagir com interface, são utilizados comandos de teclado (PUBLISH)
// l = entrada ligar
// r = entrada reset
// m = entrada mode
// d = entrada desarmar
//-----------------------------------------------------------------------------

//Bibliotecas Java
import java.io.IOException;
import java.time.format.DateTimeFormatter;  
import java.time.LocalDateTime;
//Bibliotecas Processing
import mqtt.*;
import ddf.minim.*;

//----------------------------- Conexão MQTT ----------------------------------
String user   = "grupo1-bancadaB5";
String passwd = "L%40Bdygy1B5";      // manter %40
String broker = "3.141.193.238";     
String port   = "80";
MQTTClient client;
String clientID;
//-----------------------------------------------------------------------------

//-------------------------------- Variaveis ----------------------------------
int whichKey = -1;  // variavel mantem tecla acionada
Boolean estado_ligar = false;
Boolean estado_mode = false;
Boolean estado_reset = false;
Boolean estado_selmux0 = false;
Boolean estado_selmux1 = false;
Boolean estado_alerta = false;
Boolean estado_calibrando = false;
Boolean estado_desarmar = false;
Boolean estado_senha = false;
String senha = "";
PFont myFont;
int largura = 960;
int altura = 600;
PrintWriter QuietWatch_logger;
Minim minim;
AudioPlayer som_calibrando, som_alarme;
//-----------------------------------------------------------------------------

//------------------------- Setup: executado uma vez --------------------------
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
  client.publish(user + "/E0home", "0");//reset
  client.publish(user + "/E1home", "0");//ligar
  client.publish(user + "/E2home", "0");//mode
  client.publish(user + "/E3home", "0");//desarmar
}
//-----------------------------------------------------------------------------

//----------------------- Draw: executado continuamente -----------------------
void draw() { 
    cursor(HAND);
    textFont(myFont);
    background(#B6BCB3);    
    // chama funcoes para desenhar painel do sistema de segurança
    drawCabecalho();
    drawQuadro();
}
//-----------------------------------------------------------------------------


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
    text("m: E2 (modo 0 'em casa' ou 1 'fora de casa')", 10, 70, largura, altura);
    textAlign(CENTER);
    textSize(15);
    fill(0);
    text("d: E3 (desarmar)", 10, 85, largura, altura);
    
}
void drawQuadro(){
  stroke(#300A8B);
  fill(#868489);
  rect(250, 100, 500, 410);
//--------------------------- Widgets para Inputs ----------------------------
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
  if(estado_desarmar){// d de desarmar(E3)
    fill(#FF0303);
    ellipse(350, 450, 70, 70);
    textSize(10);
    fill(0);
    text("Aguardando", 350, 455);//E3 = 1
  }else{
    fill(#B6BCB3);
    ellipse(350, 450, 70, 70);
    textSize(12);
    fill(0);
    text("Desarmar", 350, 455);//E3 = 0
  }
  
  //---------------------------------------------------------------------------
  stroke(255,0,0);
  strokeWeight(5);
  line(500,100,500,510);
  //-------------------------- Widgets para Outputs ---------------------------
  if(estado_alerta){
    stroke(#300A8B);
    fill(#FF0303);
    ellipse(600, 150, 70, 70);
    textSize(12);
    fill(0);
    text("alerta on", 600, 155);
  }else{
    stroke(#300A8B);
    fill(#00FF12);
    ellipse(600, 150, 70, 70);
    textSize(12);
    fill(0);
    text("alerta off", 600, 155);
  }
  if(estado_calibrando){
    stroke(#300A8B);
    fill(#FF0303);
    ellipse(600, 250, 70, 70);
    textSize(12);
    fill(0);
    text("calibrando...", 600, 255);
  }else{
    //stroke(#300A8B);
    //if(estado_ligar){
    //  fill(#00FF12);
    //  ellipse(600, 250, 70, 70);
    //  textSize(12);
    //  fill(0);
    //  text("calibrado", 600, 255);
    //}else{
    //  fill(#B6BCB3);
    //  ellipse(600, 250, 70, 70);
    //}
  }
  if(estado_senha){
    stroke(#300A8B);
    fill(#FF0303);
    ellipse(600, 370, 100, 100);
    textSize(12);
    fill(0);
    text("INSERIR SENHA", 600, 375);
  }else{
    //stroke(#300A8B);
    //fill(#B6BCB3);
    //ellipse(600, 370, 100, 100);
    //textSize(12);
    //fill(0);
    //text("", 600, 155);
  }
  //-----------------------------------------------------------------------------
  String dispTime = "Hora: " + hour() + ":" + minute() + ":" + second();
  fill(0);
  rect(605, 485, 85, 20);
  fill(#B6BCB3);
  text(dispTime, 650, 500);
}

//------------------- keyPressed: processa entrada por teclado ------------------
// funcao keyPressed - processa tecla acionada
void keyPressed() {
  whichKey = key;
  if(estado_senha){
    String key_char = str((char) whichKey);
    senha += key_char;
    if(senha.length() == 4){
      println("SENHA ENVIADA " + senha);
      QuietWatch_logger.println("SENHA ENVIADA  " + senha);
      QuietWatch_logger.flush();
      client.publish(user + "/RXhome", senha);
      senha = "";
    }
  }else{
    if(whichKey == 114){
      estado_reset = !estado_reset;
      if(estado_reset){
        client.publish(user + "/E0home", "1");
        QuietWatch_logger.println("Reset  " + hour() + ":" + minute() + ":" + second());
        QuietWatch_logger.flush();
      }else{
        client.publish(user + "/E0home", "0");
      }
    }
    if(whichKey == 108){
      estado_ligar = !estado_ligar;
      if(estado_ligar){
        client.publish(user + "/E1home", "1");
        QuietWatch_logger.println("Ligar  " + hour() + ":" + minute() + ":" + second());
        QuietWatch_logger.flush();
      }else{
        client.publish(user + "/E1home", "0");
      }
    }
    if(whichKey == 109){
      estado_mode = !estado_mode;
      if(estado_mode){
        client.publish(user + "/E2home", "1");
        QuietWatch_logger.println("Modo Fora de Casa  " + hour() + ":" + minute() + ":" + second());
        QuietWatch_logger.flush();
      }else{
        client.publish(user + "/E2home", "0");
        QuietWatch_logger.println("Modo Em Casa  " + hour() + ":" + minute() + ":" + second());
        QuietWatch_logger.flush();
      }
    }
    if(whichKey == 100){
      estado_desarmar = !estado_desarmar;
      if(estado_mode){
        client.publish(user + "/E3home", "1");
        QuietWatch_logger.println("Desarmado  " + hour() + ":" + minute() + ":" + second());
        QuietWatch_logger.flush();
      }else{
        client.publish(user + "/E3home", "0");
        QuietWatch_logger.println("Armado  " + hour() + ":" + minute() + ":" + second());
        QuietWatch_logger.flush();
      }
    }
  }
}
//-----------------------------------------------------------------------------

//----------------------------- Funções para MQTT -----------------------------
void clientConnected() {
  println("cliente conectado");
  client.subscribe(user + "/E0home");
  client.subscribe(user + "/E1home");
  client.subscribe(user + "/E2home");
  client.subscribe(user + "/E3home");
  client.subscribe(user + "/S0home");//alerta movimento
  client.subscribe(user + "/S1home");//calibrando
  client.subscribe(user + "/S2home");//senha
}

void messageReceived(String topic, byte[] payload) {
  String dados = new String(payload);
  
  if(topic.endsWith("E0home")){
    if(Integer.parseInt(dados) == 1){
      QuietWatch_logger.println("Recebido Reset  " + hour() + ":" + minute() + ":" + second());
      QuietWatch_logger.flush();
      estado_reset = true;
    }else{
      estado_reset = false;
    }
  }
  
  if(topic.endsWith("E1home")){
    if(Integer.parseInt(dados) == 1){
      QuietWatch_logger.println("Recebido Ligar  " + hour() + ":" + minute() + ":" + second());
      QuietWatch_logger.flush();
      estado_ligar = true;
    }else{
      estado_ligar = false;
    }
  }
  
  if(topic.endsWith("E2home")){
    if(Integer.parseInt(dados) == 1){
      QuietWatch_logger.println("Recebido Modo Fora de Casa  " + hour() + ":" + minute() + ":" + second());
      QuietWatch_logger.flush();
      estado_mode = true;
    }else{
      QuietWatch_logger.println("Recebido Modo Em Casa  " + hour() + ":" + minute() + ":" + second());
      QuietWatch_logger.flush();
      estado_mode = false;
    }
  }
  if(topic.endsWith("E3home")){
    if(Integer.parseInt(dados) == 1){
      QuietWatch_logger.println("Recebido Desarmado  " + hour() + ":" + minute() + ":" + second());
      QuietWatch_logger.flush();
      estado_desarmar = true;
    }else{
      QuietWatch_logger.println("Recebido Armado  " + hour() + ":" + minute() + ":" + second());
      QuietWatch_logger.flush();
      estado_desarmar = false;
    }
  }
  
  if(topic.endsWith("S0home")){//mensagem veio de S0 (alerta_mov)
    if(Integer.parseInt(dados) == 1){//alerta esta ativado
      DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");  
      LocalDateTime now = LocalDateTime.now();
      if(estado_alerta == false){
        println("ALERTA DE MOVIMENTO : " + dtf.format(now));
        QuietWatch_logger.println("ALERTA DE MOVIMENTO  " + hour() + ":" + minute() + ":" + second());
        QuietWatch_logger.flush();
        if(estado_mode){
          som_alarme.play();
        }
        estado_alerta = true;
      }
    }else{
      estado_alerta = false;
      som_alarme.pause();
    }
  }
  
  if(topic.endsWith("S1home")){//mensagem veio de S1 (calibrando)
    if(Integer.parseInt(dados) == 1){//alerta esta ativado
      DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");  
      LocalDateTime now = LocalDateTime.now();
      if(estado_calibrando == false){
        println("Calibrando : " + dtf.format(now));
        QuietWatch_logger.println("Calibrando  " + hour() + ":" + minute() + ":" + second());
        QuietWatch_logger.flush();
        estado_calibrando = true;
      }
    }else{
      estado_calibrando = false;
    }
  }
    
  if(topic.endsWith("S2home")){//mensagem veio de S2
    if(Integer.parseInt(dados) == 1){
      DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");  
      LocalDateTime now = LocalDateTime.now();
      if(estado_senha == false){
        println("Senha : " + dtf.format(now));
        QuietWatch_logger.println("Inserir Senha  " + hour() + ":" + minute() + ":" + second());
        QuietWatch_logger.flush();
        estado_senha = true;
      }
    }else{
      estado_senha = false;
    }
  }
}
void connectionLost() {
  println("conexao perdida");
}
//---------------------------------------------------------------------------
