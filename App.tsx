/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * Generated with the TypeScript template
 * https://github.com/react-native-community/react-native-template-typescript
 *
 * @format
 */

import React, {useEffect, useState} from 'react';
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
import {fetchData} from './data';
const App = () => {
  const isDarkMode = useColorScheme() === 'dark';
  const [data, setdata] = useState<any>(null);
  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  useEffect(() => {
    (async () => {
      setdata(await fetchData());
    })();
  }, []);

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
            disabled={data ? false : true}
            title="Init ZOOM"
            onPress={() => initZoom(data.init_sdk_jwt_token, 'zoom.us')}
          />

          <Button
            disabled={data ? false : true}
            title="joinMeeting"
            onPress={() =>
              joinMeeting(`${data.meeting_id}`, data.meeting_password)
            }
          />

          <Button
            disabled={data ? false : true}
            title="start meeting"
            onPress={() =>
              startMeeting({
                meetingNumber: `${data.meeting_id}`,
                zoomAccessToken: data.zoom_zak_token,
                userId: data.user_zoom_id,
                userName: 'dawi',
                userType: 1,
              })
            }
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

export default App;
