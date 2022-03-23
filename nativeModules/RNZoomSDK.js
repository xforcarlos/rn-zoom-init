import {NativeModules} from 'react-native';

const {zoom} = NativeModules;

console.log(zoom);

const isInitialized = async () => await zoom.isInitialized();

async function initZoom(jwtToken, domain) {
  console.log('isInitialized', await isInitialized());
  const response = await zoom.initZoom(jwtToken, (domain = 'zoom.us'));
  console.log('initZoom', response);
  console.log('isInitialized', await isInitialized());
}

async function startMeeting(params) {
  if (await isInitialized()) {
    try {
      const response = await zoom.startMeeting({...params});
      console.log('startMeeting', response);
    } catch (error) {
      console.log('error', error);
    }
  } else {
    console.log('Please Initializ first');
  }
}

async function joinMeeting(meetingNumber, meetingPassword) {
  const response = await zoom.joinMeeting(meetingNumber, meetingPassword);
  console.log('Response - Join Meeting', response);
}

export {initZoom, joinMeeting, startMeeting};
