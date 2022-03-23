import {NativeModules} from 'react-native';

const {zoom} = NativeModules;

console.log(zoom);

const isInitialized = async () => await zoom.isInitialized();

async function initZoom(jwtToken, domain) {
  const response = await zoom.initZoom(jwtToken, (domain = 'zoom.us'));
  console.log('initZoom', response);
  isInitialized();
}

async function startMeeting(params) {
  try {
    const response = await zoom.startMeeting({...params});
    console.log('startMeeting', response);
  } catch (error) {
    console.log('error', error);
  }
}

async function joinMeeting(meetingNumber, meetingPassword) {
  const response = await zoom.joinMeeting(meetingNumber, meetingPassword);
  console.log('Response - Join Meeting', response);
}

export {initZoom, joinMeeting, startMeeting};
