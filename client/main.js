import {
    CognitoUserPool,
    CognitoUserAttribute,
    CognitoUser,
    AuthenticationDetails
} from 'amazon-cognito-identity-js';
import { AWSAppSyncClient } from 'aws-appsync';
import gql from 'graphql-tag';

import('./elm.compiled.js').then(function ({Elm}) {
    var appSyncClient = null;
    const app = Elm.Main.init({flags: process.env.LS_API_URL});

    const registerHandler = function (data) {
        const poolData = {
            UserPoolId : process.env.LS_COGNITO_USER_POOL_ID,
            ClientId : process.env.LS_COGNITO_CLIENT_ID
        };
        const userPool = new CognitoUserPool(poolData);

        const dataEmail = {
            Name : 'email',
            Value : data.email
        };
        const attributeEmail = new CognitoUserAttribute(dataEmail);
        const dataOrg = {
            Name: 'custom:organization',
            Value: data.organization
        };
        const attributeOrganization = new CognitoUserAttribute(dataOrg)

        const attributeList = [
            attributeEmail,
            attributeOrganization
        ];

        userPool.signUp(data.username, data.password, attributeList, null, function(err, result){
            if (err) {
                console.log(err);
                app.ports.registerFailure.send([err.code, err.message]);
                return;
            }
            app.ports.registerSuccess.send(null);
        });
    };

    const confirmUserHandler = function (data) {
        const poolData = {
            UserPoolId : process.env.LS_COGNITO_USER_POOL_ID,
            ClientId : process.env.LS_COGNITO_CLIENT_ID
        };
        const userPool = new CognitoUserPool(poolData);
        const userData = {
          Username: data.username,
          Pool: userPool
        };

        const cognitoUser = new CognitoUser(userData);
        cognitoUser.confirmRegistration(data.code, true, function (err, result) {
          if (err) {
            console.log(err.stack);
            app.ports.confirmUserFailure.send(err.code);
            return
          }
          app.ports.confirmUserSuccess.send(null);
      });
    };

    const loginHandler = function (data) {
        const authenticationData = {
            Username : data.username,
            Password : data.password,
        };
        const authenticationDetails = new AuthenticationDetails(authenticationData);
        const poolData = {
            UserPoolId : process.env.LS_COGNITO_USER_POOL_ID,
            ClientId : process.env.LS_COGNITO_CLIENT_ID
        };
        const userPool = new CognitoUserPool(poolData);
        const userData = {
            Username : data.username,
            Pool : userPool
        };
        const cognitoUser = new CognitoUser(userData);
        cognitoUser.authenticateUser(authenticationDetails, {
            onSuccess: function (result) {
                const idToken = result.getIdToken().getJwtToken();
                appSyncClient = new AWSAppSyncClient(
                  {
                    disableOffline: true,
                    url: process.env.LS_API_URL,
                    region: 'eu-west-1',
                    auth: {
                      type: 'AMAZON_COGNITO_USER_POOLS',
                      jwtToken: async () => idToken
                    }
                  }
                );
                app.ports.loginSuccess.send(idToken);
            },
            onFailure: function(err) {
                console.log(err);
                app.ports.loginFailure.send(err.code)
            },

        });
    };

    const uploadHandler = function (data) {
        const node = document.getElementById(data.id);
        if (node === null) {
            return;
        }

        const file = node.files[0];
        console.log('upload file', file)
    };

    const toAppSyncHandler = function (idWithMsg) {
      const data = idWithMsg.msg.data
      const operation = idWithMsg.msg.operation
      const id = idWithMsg.id
      switch (operation) {
        case "CreateDocumentLabel":
        const mutation = gql`
          mutation createLabel {
            createLabel(labelType: "${data.labelType}", label: "${data.label}") {
              ref
              label
              labelType
            }
          }
        `;
        appSyncClient.mutate(
          { mutation: mutation }
        ).then(function (result) {
          app.ports.fromAppSync.send(
            { id: id, msg: { operation: operation, data: result.data.createLabel }}
          );
        }).catch(console.error);
      }
    };

    app.ports.register.subscribe(registerHandler);
    app.ports.confirmUser.subscribe(confirmUserHandler);
    app.ports.login.subscribe(loginHandler);
    app.ports.upload.subscribe(uploadHandler);
    app.ports.toAppSync.subscribe(toAppSyncHandler);
});
