const functions = require('firebase-functions');
const admin = require('firebase-admin');
const logger = require('firebase-functions/logger');
const axios = require('axios');

admin.initializeApp();

const storage = admin.storage();
const db = admin.firestore();

exports.processVerificationsDownload = functions.https.onCall(async (data, context) => {
  const { projectId } = data;  // Extract projectId from the input data

  if (!projectId) {
    throw new functions.https.HttpsError('invalid-argument', 'The function must be called with a valid projectId.');
  }
  
  try {
    const { clipsData, verificationsData, usersEmails } = await prepareClipDataArgs(projectId);
    const result = await generateClipData(clipsData, verificationsData, usersEmails);
    
    logger.info('Data generated successfully');
    return { success: true, data: result };
  } catch (error) {
    logger.error('Error processing audio download:', error.message);
    throw new functions.https.HttpsError('internal', 'Failed to process audio download.', error);
  }
});

/// Helper functions for processAudioDownload function ///
async function prepareClipDataArgs(projectId) {
  // Fetch audio clips data from Firestore
  const projectClipsRef = db.collection(`AudioClips/${projectId}/clips`);
  const clipsSnapshot = await projectClipsRef.where('isVerified', '==', true).get();

  const clipsData = [];
  clipsSnapshot.forEach(doc => {
    const clipWithId = {
      id: doc.id,
      ...doc.data(),
    };
    clipsData.push(clipWithId);
  });

  // Fetch verifications data from Firestore
  const verificationsSnapshot = await db.collection('Verifications')
    .where('projectId', '==', projectId)
    .get();

  const verificationsData = new Map();
  verificationsSnapshot.forEach(doc => {
    const data = doc.data();
    verificationsData.set(data.audioClipId, data);
  });

  // Fetch users data from Firestore
  const usersQuery = db.collection('Users').where('projects', 'array-contains', projectId);
  const usersEmails = new Map();

  const querySnapshot = await usersQuery.get();
  querySnapshot.forEach(doc => {
    const userData = doc.data();
    usersEmails.set(doc.id, userData.email);
  });

  return { clipsData, verificationsData, usersEmails };
}

async function generateClipData(clipsData, verificationsData, usersEmails) {
  const headerMap = {
    clipBasename: 'Clip Basename',
    beginFile: 'Begin File',
    createdAt: 'Uploaded Datetime',
    verificationDate: 'Verification Datetime',
    beginTime: 'Begin Time',
    endTime: 'End Time',
    lowFreq: 'Low Freq',
    highFreq: 'High Freq',
    predictedCommonName: 'Predicted Common Name',
    predictedSpeciesCode: 'Predicted Species Code',
    confidence: 'Confidence',
    verifiedBy: 'Verified By',
    verifiedAsSpeciesCode: 'Verified As Species Code',
    verifiedAsCommonName: 'Verified As Common Name',
    predictionIsCorrect: 'Prediction Was Correct',
    tags: 'Tags',
    userConfidence: 'User Confidence',
  };

  const data = clipsData.map(clip => {
    const verification = verificationsData.get(clip.id);
    const userEmail = verification ? usersEmails.get(verification.verifiedBy) : '';

    if (verification && !verification.userConfidence) {
      verification.userConfidence = null;
    }
    if (verification && !verification.tags) {
      verification.tags = [];
    }

    let dateObject = verification ? verification.verifiedAt?.toDate() : '';
    if (dateObject instanceof Date) {
      verification.verifiedAt = dateObject.toISOString();
    } else {
      verification.verifiedAt = 'NODATE';
    }

    dateObject = clip.createdAt?.toDate();
    clip.createdAt = dateObject instanceof Date ? dateObject.toISOString() : 'NODATE';

    const dataRow = Object.keys(headerMap).reduce((acc, key) => {
      switch (key) {
        case 'verifiedBy':
          acc[headerMap[key]] = userEmail;
          break;
        case 'verificationDate':
          acc[headerMap[key]] = verification ? verification.verifiedAt : '';
          break;
        case 'verifiedAsSpeciesCode':
          acc[headerMap[key]] = verification ? verification.verifiedAsSpeciesCode : '';
          break;
        case 'verifiedAsCommonName':
          acc[headerMap[key]] = verification ? verification.verifiedAsCommonName : '';
          break;
        case 'predictionIsCorrect':
          acc[headerMap[key]] = verification ? verification.predictionIsCorrect : '';
          break;
        case 'tags':
          acc[headerMap[key]] = verification ? verification.tags.join(', ') : '';
          break;
        case 'userConfidence':
          acc[headerMap[key]] = verification ? verification.userConfidence : '';
          break;
        default:
          acc[headerMap[key]] = clip[key] || '';
      }
      return acc;
    }, {});

    return dataRow;
  });

  return data;  // Return the data as an array of objects
}