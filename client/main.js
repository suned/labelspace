import { CognitoUserPool, CognitoUserAttribute, CognitoUser, AuthenticationDetails } from 'amazon-cognito-identity-js';

import('./elm.compiled.js').then(function ({Elm}) {
    const app = Elm.Main.init();
    app.ports.register.subscribe(function (data) {
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

        const attributeList = [
            attributeEmail
        ];

        userPool.signUp(data.username, data.password, attributeList, null, function(err, result){
            if (err) {
                console.log(err)
                app.ports.registerFailure.send(err);
                return;
            }
            app.ports.registerSuccess.send(null);
        });
    });

    app.ports.confirmUser.subscribe(function (data) {
        const poolData = {
            UserPoolId : process.env.LS_COGNITO_USER_POOL_ID,
            ClientId : process.env.LS_COGNITO_CLIENT_ID
        };
        const userPool = new CognitoUserPool(poolData);
        const userData = {
          Username: data.username,
          Pool: userPool
        }
      
        const cognitoUser = new CognitoUser(userData)
        cognitoUser.confirmRegistration(data.code, true, function (err, result) {
          if (err) {
            console.log(error)
            app.ports.confirmFailure.send(err.message);
            return
          }
          app.ports.confirmUserSuccess.send(null);
      });
    });

    app.ports.login.subscribe(function (data) {
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
                const accessToken = result.getAccessToken().getJwtToken();
                app.ports.loginSuccess.send(accessToken);  
            },
    
            onFailure: function(err) {
                console.log(error);
            },
    
        });
    });

    app.ports.readFile(function (id) {
        const node = document.getElementById(id);
        if (node === null) {
            return;
        }

        const file = node.files[0];
        const reader = new FileReader();

        reader.onload = (function(event) {
            var base64encoded = event.target.result;
            var portData = {
                contents: base64encoded,
                filename: file.name
            };

            app.ports.fileContentRead.send(portData);
        });
    });
});
