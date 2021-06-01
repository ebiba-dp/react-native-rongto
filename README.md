# react-native-rongta

## Getting started

`$ npm install react-native-rongta --save`

## Usage
```javascript
import ReactNativeRongta from 'react-native-rongta';


//get all devices
ReactNativeRongta.getDevicesList()

ReactNativeRongta.getDevicesList((error, devicesList) => {
      
});

//connect to a specific device
ReactNativeRongta.connectToDevice(id)

DanielRNRongta.connectToDevice( id,
      (result) => {
        if(result == "1") {
          // Successful connection
        } else {
          // connection failed
        }
      }
);

//print a text
ReactNativeRongta.print("text")
