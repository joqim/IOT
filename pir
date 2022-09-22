#include <Arduino.h>
#include "painlessMesh.h"

#define   MESH_PREFIX     "Group6"
#define   MESH_PASSWORD   "Group6Password"
#define   MESH_PORT       5555
#define   PIR             4

Scheduler userScheduler; // to control your personal task
painlessMesh  mesh;

// User stub
void sendMessage() ; // Prototype so PlatformIO doesn't complain

Task taskSendMessage( TASK_SECOND * 1 , TASK_FOREVER, &sendMessage );

bool prevState = true;
bool curState = false;

void sendMessage() {
  String msg = "P,";
  msg += mesh.getNodeId();
  if(curState){
    msg += ", On";
  }else{
    msg += ",Off";
  }

  mesh.sendBroadcast( msg );

}

// Needed for painless library
void receivedCallback( uint32_t from, String &msg ) {
  Serial.printf("startHere: Received from %u msg=%s\n", from, msg.c_str());
}

void newConnectionCallback(uint32_t nodeId) {
    Serial.printf("--> startHere: New Connection, nodeId = %u\n", nodeId);
}

void changedConnectionCallback() {
  Serial.printf("Changed connections\n");
}

void nodeTimeAdjustedCallback(int32_t offset) {
    Serial.printf("Adjusted time %u. Offset = %d\n", mesh.getNodeTime(),offset);
}

void setup() {
  Serial.begin(115200);

//mesh.setDebugMsgTypes( ERROR | MESH_STATUS | CONNECTION | SYNC | COMMUNICATION | GENERAL | MSG_TYPES | REMOTE ); // all types on
  mesh.setDebugMsgTypes( ERROR | STARTUP );  // set before init() so that you can see startup messages

  mesh.init( MESH_PREFIX, MESH_PASSWORD, &userScheduler, MESH_PORT );
  mesh.onReceive(&receivedCallback);
  mesh.onNewConnection(&newConnectionCallback);
  mesh.onChangedConnections(&changedConnectionCallback);
  mesh.onNodeTimeAdjusted(&nodeTimeAdjustedCallback);

  // userScheduler.addTask( taskSendMessage );
  // taskSendMessage.enable();
}

void loop() {
  // it will run the user scheduler as well
  mesh.update();
  curState = digitalRead(PIR);
  if(prevState != curState){
    sendMessage();
    prevState = curState;
  }
  
  
  
}
