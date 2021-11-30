# sistema-seguranca

Esse repositório contém o projeto ***Sistema de Segurança*** desenvolvido na disciplina Laboratório Digital II. O projeto vai ser desenvolvido em três 3 sprints, detalhados abaixo.

## Semana 1: Jornada Básica

O objetivo da Semana 1 do projeto é a implementação das funcionalidades básicas do projeto, suprindo os requisitos funcionais da Jornada Básica do usuário.

### Requisitos Funcionais

O sistema proposto ***no modo de segurança*** deve identificar se houve alguma movimentação no interior de um cômodo e entrar ***no modo de alerta*** caso ocorra a detecção. No modo de alerta é enviada uma mensagem de alerta utilizando a ***UART*** no formato:

> ALERTA horario angulo,distancia

Onde ***horario***, ***angulo*** e ***distancia*** representam o horário da detecção, a posição do servomotor onde foi detectado o movimento e a distância medida pelo sensor ultrassônico nessa posição, respectivamente.

No modo de alerta é ativado um ***buzzer***. O alerta também pode ser visto no celular do cliente pelo aplicativo ***MQTT Dash***

### Requisitos Não-Funcionais

Para detectar o movimento, o sistema deve considerar também a ***imprecisão da medição*** e a ***condição do ambiente*** para gerar a sensibilidade do sensor. 

Dessa forma, foi para uma dada medida é definido um intervalo de sensibilidade onde a variação não é considerada suficiente para acionar o alerta.

### Requisitos Físicos

A princípio, são necessários os componentes do ***Kit Home Lab*** que irão interagir com a infraestrutura física do ***Lab EAD*** da disciplina Laboratório Digital II. Como o sonar será reaproveitado para o projeto do grupo, precisa-se do ***servomotor SG90*** e do ***sensor HC-SR04***, além da ***placa Wemos D1 R1*** que possui o componente ***ESP8266***.

A funcionalidade de senha foi implementada usando Arduino, portanto é exclusiva do kitHome. Para possibilitar demonstrações na infraestrutura do LabEAD é possível desativar a funcionalidade de senha com um sinal de entrada. Nesse modo de teste, não é necessária a interação com Arduino. O DashBoard Processing e o Notebook Google Colab operam nesse modo de teste.

Para intermediar a comunicação com a FPGA do laboratório, também é possível usar o aplicativo ***MQTT Dash***.

### Implementação

![Pseudocódigo](algoritmo_semana1.png)

#### Persistência de dados de eventos

O DashBoard Processing armazena todos os dados de sua sessão em arquivo txt.
