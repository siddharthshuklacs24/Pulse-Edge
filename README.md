hackathon flow:
1)deep and detailed prompt about the problem statement and project flow after thinking it through
2)correct roles dividing
3)correct project structure and git cloned in everyone's local laptop
4)optimal cross exchange of info and files(2 members)+UI and PPT(as much as possible)(2 members)
5)individual development and pushing into respective branches
6)integration(all steps for this given below)


way to git push:(solving the arrow mark error)
(do this all in codespace)
step 0:remove any .git inside the folder that you are trying to upload
step 1:rm -rf v2/mobile_app/.git
step 2:git add and commit


process for merging the codes in two branches
1. pull the main branch git clone -> git clone https://github.com/nazu777/practice_hackathon.git -> git fetch origin (might need) THIS IS FOR THE FIRST TIME
   IF U R IN THE MIDDLE OF THE PROJECT AND U WANT TO PUSH SOMETHING SO FIRST GO TO THE DIRECTORY WHERE U HAD DONE git clone THEN run git pull -> this is to sync the github and ur local repo
   1.1 git branch <branch_name> (to create a branch)
   1.2 git checkout <branch_name> 
   1.3 git add . -> git commit -m "pineapple pizza is better" -> (git push IF DOING FROM SECOND TIME, ELSE git push -u origin <branch_name>)
2. go inside the folder of main branch -> cd practice_hackathon
3. then pull the child branch -> git checkout shreyansh_ui_updated_folder_name_match
4. now merge with main -> git merge origin/main (might show errors)
5. resolve the easy conflicting files that can be taken from main directly ex: generated_plugin_registrant.cc, generated_plugins.cmake, .metadata, pubspec.lock. swift
   execute the above function using this -> git checkout --theirs v2/mobile_app/windows/flutter/generated_plugin_registrant.cc
6. the source control is the block <img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/dd670841-fc5f-49c3-9051-41f2be0447c7" /> if here, u can see the files that are in conflict with the two branches, so once u click it u can resolve by giving both versions to ai and taking the integrated version. Click the + icon once the changes have been made to a file, there is resolve by merge editor too -> left one represents main branch and right represents the child branch.
Note: the changes will still show the errors until all the files are resolved and commited (that doesnt mean the changes aint saved)
shutting down of pc will not loose the data of the chages made. (undo the changes made).
after shut down we can get to the current state by <img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/cbba5e06-81db-4da7-b6b8-2e0fc2d5a8d5" />
7. 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 -> token of nazu777. it will expire in 30 days -> https://github.com/settings/tokens -> this will be used during git push.


process for implementing login(in case of independent mobile app(no reliance on laptop):
step 1:go to firebase,login and set up authentication(gmail only to save time)
step 1.5:set up firestore database(or whichever is suitable to your project)
step 2:settings->general->your apps->android:
   step 1(register app):
      fill package name(applicationID in android/app/build.gradle.kts)
      nickname up to you 
      then register app
   step 2(download and then add config file):
      download the json file and move it into mobile_app/android/app/  (beside src and build.gradle.kts)
   step 2.5(configure your project to be able to have firebase sdk):
      open pubspec.yaml and add these dependencies:
         firebase_core: ^3.13.0
         firebase_auth: ^5.5.0
         cloud_firestore: ^5.4.3(enable google API or else this will throw error:
                           https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=pulseedge-98498  )
      flutter pub get
   step 3(making google services available to firebase SDKs):
      adding this to project level build.gradle.kts: id("com.google.gms.google-services") version "4.4.4" apply false 
      add this to app level build.gradle.kts: id("com.google.gms.google-services")
   step 4:
      continue to console
step 3(initialise flutter in firebase):
   go to main.dart and do the following changes:
      import 'package:firebase_core/firebase_core.dart';
      
      Then modify your main() function
      
      Change it to:
      
         void main() async {
           WidgetsFlutterBinding.ensureInitialized();
         
           await Firebase.initializeApp();
         
           runApp(const MyApp());
         }
   step 4:the implementation(so that user can see!):
      this depends on the specific hackathon because this is basically UI integration to the backend logic,the backend logic implementaion has been discussed in above steps
      
      
NEED FOR VIRTUAL ENVIRONMENT(TO RUN TENSORFLOW):
   py -3.11 -m venv venv
   .\venv\Scripts\activate
   pip install -r requirements.txt

CONVERTING APP TO APK:
   flutter build apk --release
   
   then share this file to whatsapp: 
      practice_hackathon\v2\mobile_app\build\app\outputs\flutter-apk\app-release.apk

PROMPT FOR OUR 12 HOUR HACKATHON PROJECT

so we are thinking of building a project in which we basically tell the user to do/avoid certain actions based on his current actions(to avoid cardiac arrest and such heart related calamities)
we plan to divide this project in 3 phases:
phase 1:we will be assessing the risk(the probability) of that person likely to experience a heart failure 
user will enter all the details(11 columns) within that particular dataset and the model is going to return a single float value between 0 to 1.
we will be dividing ranges in the following way:
0 to 0.3-low risk
0.3 to 0.6-medium risk
>.6-high risk

this is the dataset we will be using:https://www.kaggle.com/datasets/fedesoriano/heart-failure-prediction/discussion?sort=hotness

phase 2:now we will be using accelerometer to get the intensity of the activity that the user is currently doing and we need to scale this to 0 to 1 and then multiply this to the float value that we got in phase 1.This result value should be produced at every 10 seconds.

plot the accelemeter values in the graph to verify that the current action being performed and the accelerometer values are in sync or not.

based on the intensity,we will also show the user's current action(sitting,walking,running)
we will again need the reasonable ranges from you for the intensity between 0 to 1 to decide the user's current action

Based on this result values,we will give the appropriate actions(like sit down,stop running) according to the threshold values that we are yet to decide.
We need to decide the range of final result values(risk*intensity) for each particular action
for example:0 to .3 can be vitals stable,.3 to .6 can be stop sprinting,you can walk/jog/sit instead,>.6 can be sit down immediately and rest for a while.
these values are just examples,you will need to provide the actual reasonable ranges for the final product(risk*intensity)

also when the prediction is vitals stable,no need to alert(vibrate the phone) but when the other 2nd last case happens,we need to send a vibration to alert,when the last case happens(stop and rest case),we need to alert the user by the vibration and an audible sound.

phase 3:now to avoid this scenario:
suppose a high risk user starts running,he will immediately get an alert telling him to sit down and take rest,what we do is we give a 1 minute delay to the starting prediction,and after 1 minute we compare the previous prediction to the current prediction and if they are same then we actually give the alert,if they are different,the recent most prediction dominates.

the flow of the project will be like this:
1)the user opens the app and is prompted to login
2)the user is prompted to fill the relevant details for the assessment of the static risk
3)after this,it will show the risk and also show the user's current status(sitting,walking,running) 
and based on the user's result product(risk*intensity),it will show the recommended action(along with the vibration and audible sound if needed)

divide this project into a team of 4 members such that all members have equal or atleast reasonably equal workload and can work in concurrency.

also give the overall project folder structure(1 guy will be creating this repo and others will be cloning it)


TEAM DIVISION:
 (4 Members for Maximum Concurrency)To avoid stepping on each other's toes, divide the app into strict modular components.
 Member 1: Data Scientist / ML Engineer (The "Static" Guy)
    Focus: Phase 1.Tasks: Clean the Kaggle dataset, train the predictive model (Random Forest, XGBoost, or a Neural Network), and containerize it. They will build a lightweight Python backend (FastAPI/Flask) that accepts the 11 inputs and returns the float (0 to 1).Concurrency: Can start immediately; doesn't need the mobile app to be ready.
 Member 2: Frontend & UI/UX Developer (The "Visuals" Guy)
    Focus: App flow, UI, and visual logic.Tasks: Build the Login screen, the 11-question form, and the main Dashboard. They are responsible for implementing the live graph that plots the accelerometer values, and the UI state changes (green/yellow/red screens based on the final product).Concurrency: Can mock the ML and accelerometer data to build out the screens immediately.
 Member 3: Mobile Systems & Sensor Engineer (The "Hardware" Guy)
    Focus: Phase 2.Tasks: Hooking into the native Android/iOS accelerometer APIs. Writing the math logic to convert raw $x, y, z$ arrays into the 0-1 intensity scale. Emitting this value every 10 seconds.Concurrency: Focuses entirely on background services and device hardware APIs.
 Member 4: Backend / Core Logic Integrator (The "Glue" Guy)
    Focus: Phase 3 and overall data flow.Tasks: Setting up the authentication (Firebase/Supabase), storing the static risk value so the user doesn't have to fill the form twice, and writing the "Debounce/1-Minute Delay" logic. They will take Member 3's 10-second data, run the time-delay comparison logic, calculate the final product, and trigger the OS-level vibration/audio alerts.



