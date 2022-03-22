/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * Generated with the TypeScript template
 * https://github.com/react-native-community/react-native-template-typescript
 *
 * @format
 */

import React from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  useColorScheme,
  View,
  Button,
} from 'react-native';

import {Colors, Header} from 'react-native/Libraries/NewAppScreen';
import {initZoom, joinMeeting, startMeeting} from './nativeModules/RNZoomSDK';

const ZOOM_CONFIG = {
  ZOOM_PUBLIC_KEY: '',
  ZOOM_PRIVATE_KEY: '',
  ZOOM_DOMAIN: 'zoom.us',
  JWT_API_KEY: '',
  JWT_API_SECRET_KEY: '',
};

const meetingNo = '';
const pwd = '';
const userId = '';
const userName = '';

const App = () => {
  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={backgroundStyle}>
        <Header />
        <View
          style={{
            backgroundColor: Colors.white,
            justifyContent: 'space-around',
          }}>
          <Button
            title="Init ZOOM"
            onPress={() =>
              initZoom(
                ZOOM_CONFIG.ZOOM_PUBLIC_KEY,
                ZOOM_CONFIG.ZOOM_PRIVATE_KEY,
                ZOOM_CONFIG.ZOOM_DOMAIN,
              )
            }
          />

          <Button
            title="joinMeeting"
            // onPress={() => joinMeeting(userName, meetingNo, pwd)}
          />

          <Button
            title="start meeting"
            // onPress={() =>
            // startMeeting(
            //   meetingNo,
            //   userName,
            //   userId,
            //   ZOOM_CONFIG.JWT_API_KEY,
            //   ZOOM_CONFIG.JWT_API_SECRET_KEY,
            // )
            // }
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

export default App;
