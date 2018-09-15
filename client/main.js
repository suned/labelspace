import { CognitoUserPool, CognitoUserAttribute, CognitoUser } from 'amazon-cognito-identity-js';

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
            app.ports.confirmFailure.send(err.message)
            return
          }
          app.ports.confirmUserSuccess.send(null)
      })
    });
});
