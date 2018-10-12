import {
    CognitoUserPool,
    CognitoUserAttribute,
    CognitoUser,
    AuthenticationDetails
} from 'amazon-cognito-identity-js';

import('./elm.compiled.js').then(function ({Elm}) {
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
            console.log(err);
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

    app.ports.register.subscribe(registerHandler);
    app.ports.confirmUser.subscribe(confirmUserHandler);
    app.ports.login.subscribe(loginHandler);
    app.ports.upload.subscribe(uploadHandler);
});
