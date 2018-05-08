## Add Two Factor Authentication with Nexmo's Verify API in Swift 

[Two-factor authentication](https://www.nexmo.com/blog/2014/11/11/why-two-factor-authentication-2fa/) (2FA) adds an extra layer of security for users that are accessing sensitive information. 

While there are multiple modes of authenticating as with something you know, are or have, we will focus exclusively on the last. In this tutorial we will cover how to add two factor authentication for a user's phone number.  

In this tutorial we explain to implement Two Factor Authentication with Nexmo's Verify API endpoint. 

The app will need to do a few things:
 - Make a network call to three endpoints: Start a verification, check a verification code, and cancel a verification request
 - Store a `request_id` as a `responseId` so that a verification request can be cancelled or completed.

 HTTP body 

## Nexmo Setup
You need to setup an account with Nexmo. You can start the sign up here: https://dashboard.nexmo.com/sign-up

1. Create an account 
2. Make an app for Verify
3. Grab your `applicationId` & `sharedSecretKey` 

> Note: The `applicationId` & `sharedSecretKey` display differently in different browsers. In Safari the `applicationID` & `sharedSecretKey` display **after** pressing a `+` sign next to the app's name; in Firefox, however, there is no need to press a `+` sign, since both of these details display automatically. Let us know what happens in Chrome or Opera! 

## Environment setup 

- Download the starter project, a single view application: 
``` 
git clone https://www.github.com/ericgiannini/com.nexmo.nexmo-verify-ios-demo
```
- Add a CocoaPods file to its root directory, and install the pod after modifying its podfile to include the following: 

```
      pod 'Alamofire'
```

- Make sure to have an iPhone with a SIM card handy

- To correctly configure the environment we need to simulate a server as in the Glitch server app: https://glitch.com/edit/#!/nexmo-verify?path=README.md:1:0.  To configure go to .env and set the values as required for `applicationId` & `sharedSecretKey`

> Note: If you are unfamiliar with Xcode, then try out Apple's own **Intro to App Development with Swift**: https://itunes.apple.com/us/book/intro-to-app-development-with-swift/

# Review the UI

With the setup out of the way let's review user interface for verification and confirmation. 

1. a CocoaTouch file called `VerificationViewController` that is a subclass of UIViewController; this class is assigned to a scene in `Main.storyboard` so that it takes `VerificationViewController ` as its custom class. 

2. three TextFields in `VerificationViewController`, outlets called `inputEmailAddress`, `inputPassword`, `inputTelephoneNumber` respectively.

3. a Button in `VerificationViewController` called `loginBtn`.

4. a Button in `VerificationViewController`, an action called `cancelVerification`. 

5. a segue called `authenticateWith2FACode`, connecting `VerificationViewController` to `ConfirmationViewController`.  
 
6. a CocoaTouch file called `ConfirmationViewController` that is a subclass of UIViewController; assigned to a scene in `Main.storyboard` so that it takes `ConfirmationViewController` as its custom class. 

7. a TextField, `ConfirmationViewController`, `inputEmailAddress`.

8. a Button in `VerificationViewController`, an action called `cancelVerification`. 

> Note: You are free to set the constraints for the TextFields, Buttons, or Labels however you would like! 


# Setting up the Glitch Server 

Let's break down what lies ahead. Nexmo's API for verification is essentially two links. The first one is: https://api.nexmo.com/verify/json. This link verifies the user's telephone number. The second link is: https://api.nexmo.com/verify/check/json. This link verifies that the user is in possession of the device by sending an SMS with a pin. 

In this tutorial, however, we do not directly hit either of these API endpoints. We use an SDK called `Alamofire` to communicate through an intermediary Glitch server. We upload our `applicationID` & `sharedSecretKey`.

### Steps for Setting up Server 

- The first step to setting up the Glitch server is to remix the Glitch server for your own deploymet. On the site there is a remix button: https://glitch.com/edit/#!/nexmo-verify 
- After pressing the remix button, add the `applicationID` & `sharedSecretKey` to the server. 


## Programming the UI 

With the Glitch server setup, the next step is to program the app's UI to request or respond to requests with the server.

1. At the top of `VerificationViewController` include the following lines: `import Alamofire`. 

2. Within the scope of `VerificationViewController`'s class declaration add the following line: `var responseId = String()`. We are empty initiliazing a string where we will hold a reference to our `responseId`.

> Note: You may want to use NSUserDefaults or one of the many different classes for local storage. Since it is a matter of preference we leave it to you as a developer to decide how to store the `responseId`. 

3. In the `@IBAction` for `verifyTelephoneNumber` add the following line: `self.verifyViaAPI()`, which is a function we will program to hit the first link. 
4. Create a function called `verifyViaAPI()` with the following code: 
 
```Swift
    func requestVerificationWithAPI()
    {
        //Sending SMS
        let param = ["telephoneNumber": telephoneTextField.text]
        
        Alamofire.request("https://nexmo-verify.glitch.me/request", parameters: param).responseJSON { response in
            
            print("--- Sent SMS API ----")
            print("Response: \(response)")
            
            if let json = response.result.value as? [String:AnyObject] {
                
                self.responseId = json["request_id"] as! String
            }
        }
    }
```

With the code setup our first call to the server is a post request. 

After the call is made, we analyze the response data to parse out the response request. We save the parsed value of `json["request_id"]` as a `String` value in our `responseId`. 

Inside of the body of the function we program the parameters to request the `responseId` so that we can continue to communicate with the API through the Glitch server.


### Second Link : SMS 

1. In the `@IBAction` for `verifyPin` add the following line: `self.verifyPinViaAPI()`, which is a function we will program to hit the second link. 
2. Create a function called `verifyPinViaAPI()` with the following code: 

```Swift
func verifyPinViaAPI() {
        let param = [
            "request_id": self.responseId,
            "code": pinCode]
        
        Alamofire.request("https://nexmo-verify.glitch.me/check", parameters: param).responseJSON { response in
            
            print("--- Verify SMS API ----")
            print("Response: \(response)")
            
            if let json = response.result.value as? [String:AnyObject] {
                print(json)
                
                var status = Int()
                status = Int(json["status"] as! String)!
                print(status)
                
                if status == 0 {
                    self.performSegue(withIdentifier: "authenticateWith2FA", sender: nil)
                    
                    
                }
                
            }
            
        }
    }
```
The code is similiar to the first request. In this code snippet we parse the response for a successful verification. If the status returned in the response is zero, we present the user with his or her notes. If not, then the user must start all over again. 

### Testing 

The user inputs his or her telephone number into the text field, pressing the button to verify. If all goes well, the user receives a text message on their phone; the text message contains the pin. The user inputs the pin into the text field, pressing the button to verify the pin. If the verification is successful, the users' notes appear.


# Conclusion - What's been achieved and learned?

You now have a verified number & double checked that your user is in possession of the device's number and you do this with Nexmo's API! You built a User Interface for verification & your programmed it and you hit two of Nexmo's API endpoints with Alamofire in Swift! 

With this implementation you only know from the client side that the number is verified. In a real world app, you would need to tell your backend that the number is verified. You could accomplish that in two ways. Either calling that update on the success flow from the client. Or your own callbacks.

If you struggled with any aspect of the code, then you can download the completed project [here](https://www.dropbox.com/s/b0x9hcun7b0021p/memo%202.zip?dl=0).

> Much of the code is not programmed defensively to prevent bugs. Imagine, for instance, a user who forgets to enter his or her area code in the `inputTextField` but presses the `Verify` button anyway. Imagine the user presses the button without any text at all in the label, let alone numbers. How would you program this button defensively? How would you program the other button defensively? 

# What's next? 

Congratulations! You're all set now for SMS verification. 

