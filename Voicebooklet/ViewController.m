//
//  ViewController.m
//  voicebooklet
//
//  Created by Joseph Mohr on 11/9/14.
//  Copyright (c) 2014 Joe Mohr. All rights reserved.
//

#import "ViewController.h"
#import <OpenEars/FliteController.h>
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/OpenEarsLogging.h>

@interface ViewController ()

@end

@implementation ViewController{
    NSString *lmPath;
    NSString *dicPath;
    NSString *lmPath2;
    NSString *dicPath2;
    bool gettingPost;
    NSDictionary *friends;
    int friendIndex;
    int friendSize;
    NSDictionary *news;
    int newsIndex;
    int newsSize;
    bool loggedIn;
}
@synthesize pocketsphinxController;
@synthesize openEarsEventsObserver;
@synthesize slt;
@synthesize fliteController;

// Lazily allocated slt voice.
- (Slt *)slt {
    if (slt == nil) {
        slt = [[Slt alloc] init];
    }
    return slt;
}

// Lazily allocated FliteController.
- (FliteController *)fliteController {
    if (fliteController == nil) {
        fliteController = [[FliteController alloc] init];
        
    }
    return fliteController;
}

- (OpenEarsEventsObserver *)openEarsEventsObserver {
    if (openEarsEventsObserver == nil) {
        openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
    }
    return openEarsEventsObserver;
}
- (PocketsphinxController *)pocketsphinxController {
    if (pocketsphinxController == nil) {
        pocketsphinxController = [[PocketsphinxController alloc] init];
    }
    return pocketsphinxController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    gettingPost = false;
    friendIndex = 0;
    friendSize = 0;
    newsIndex = 0;
    newsSize = 0;
    loggedIn = false;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wood"]];
    // Do any additional setup after loading the view, typically from a nib.
    FBLoginView *loginView =
    [[FBLoginView alloc] initWithReadPermissions:
     @[@"public_profile", @"email", @"user_friends", @"publish_actions", @"read_stream", @"user_status"]];
    loginView.frame = CGRectOffset(loginView.frame,(self.view.center.x - (loginView.frame.size.width / 2)), 30);
    loginView.delegate = self;
    [self.view addSubview:loginView];
    
    UIImageView *imgview = [[UIImageView alloc]
                            initWithFrame:CGRectMake(self.view.center.x - 100, 150, 200, 200)];
    [imgview setImage:[UIImage imageNamed:@"speaker"]];
    [imgview setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:imgview];
    UIButton *commandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [commandButton setBackgroundImage:[UIImage imageNamed: @"mic-blue"] forState:UIControlStateNormal];
    [commandButton setBackgroundImage:[UIImage imageNamed:
                                       @"mic-pushed"]
                             forState:UIControlStateHighlighted];
    [commandButton addTarget:self
                      action:@selector(startListening)
            forControlEvents:UIControlEventTouchUpInside];
    [commandButton setFrame:CGRectMake(self.view.center.x - 30, 400, 60, 60)];
    [self.view addSubview:commandButton];
    [self.openEarsEventsObserver setDelegate:self];
    LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
    
    NSArray *words = [NSArray arrayWithObjects:@"CURRENT STORY", @"NEXT STORY", @"PREVIOUS STORY", @"NEXT FRIEND", @"PREVIOUS FRIEND", @"MY STATUS", @"FRIEND STATUS", @"POST MESSAGE", @"CURRENT FRIEND", nil];
    NSString *name = @"NameIWantForMyLanguageModelFiles";
    NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    
    NSDictionary *languageGeneratorResults = nil;
    
    lmPath = nil;
    dicPath = nil;
    
    if([err code] == noErr) {
        
        languageGeneratorResults = [err userInfo];
        
        lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
        dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
        
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
    NSArray *words2 = [NSArray arrayWithObjects:@"THE", @"OF", @"AND", @"A", @"TO", @"IN", @"IS", @"YOU", @"THAT", @"IT", @"HE", @"WAS", @"FOR", @"ON", @"ARE", @"AS", @"WITH", @"HIS", @"THEY", @"I", @"AT", @"BE", @"THIS", @"HAVE", @"FROM", @"OR", @"ONE", @"HAD", @"BY", @"WORD", @"BUT", @"NOT", @"WHAT", @"ALL", @"WERE", @"WE", @"WHEN", @"YOUR", @"CAN", @"SAID", @"THERE", @"USE", @"AN", @"EACH", @"WHICH", @"SHE", @"DO", @"HOW", @"THEIR", @"IF", @"WILL", @"UP", @"OTHER", @"ABOU", @"OUT", @"MANY", @"THEN", @"THEM", @"THESE", @"SO", @"SOME", @"HER", @"WOULD", @"MAKE", @"LIKE", @"HIM", @"INTO", @"TIME", @"HAS", @"LOOK", @"TWO", @"MORE", @"WRITE", @"GO", @"SEE", @"NUMBER", @"NO", @"WAY", @"COULD", @"PEOPLE", @"MY", @"THAN", @"FIRST", @"WATER", @"BEEN", @"CALL", @"WHO", @"OIL", @"NOW", @"FIND", @"LONG", @"DOWN", @"DAY", @"DID", @"GET", @"COME", @"MADE", @"MAY", @"PART", @"OVER", @"NEW", @"SOUND", @"TAKE", @"ONLY", @"LITTLE", @"WORK", @"KNOW", @"PLACE", @"YEAR", @"LIVE", @"ME", @"BACK", @"GIVE", @"MOST", @"VERY", @"AFTER", @"THING", @"OUR", @"JUST", @"NAME", @"GOOD", @"SENTENCE", @"MAN", @"THINK", @"SAY", @"GREAT", @"WHERE", @"HELP", @"THROUGH", @"MUCH", @"BEFORE", @"LINE", @"RIGHT", @"TOO", @"MEAN", @"OLD", @"ANY", @"SAME", @"TELL", @"BOY", @"FOLLOW", @"CAME", @"WANT", @"SHOW", @"ALSO", @"AROUND", @"FARM", @"THREE", @"SMALL", @"SET", @"PUT", @"END", @"DOES", @"ANOTHER", @"WELL", @"LARGE", @"MUST", @"BIG", @"EVEN", @"SUCH", @"BECAUSE", @"TURN", @"HERE", @"WHY", @"WENT", @"MEN", @"READ", @"NEED", @"LAND", @"DIFFERENT", @"HOME", @"US", @"MOVE", @"TRY", @"KIND", @"HAND", @"PICTURE", @"AGAIN", @"CHANGE", @"OFF", @"PLAY", @"SPELL", @"AIR", @"AWAY", @"ANIMAL", @"HOUSE", @"POINT", @"PAGE", @"LETTER", @"MOTHER", @"ANSWER", @"FOUND", @"STUDY", @"STILL", @"LEARN", @"SHOULD", @"AMERICA", @"WORLD", @"HIGH", @"EVERY", @"NEAR", @"ADD", @"FOOD", @"BETWEEN", @"OWN", @"BELOW", @"COUNTRY", @"PLANT", @"LAST", @"SCHOOL", @"FATHER", @"KEEP", @"TREE", @"NEVER", @"START", @"CITY", @"EARTH", @"EYE", @"LIGHT", @"THOUGHT", @"HEAD", @"UNDER", @"STORY", @"DOG", @"SAW", @"LEFT", @"DON'T", @"FEW", @"WHILE", @"ALONG", @"MIGHT", @"CLOSE", @"SOMETHING", @"SEEM", @"NEXT", @"HARD", @"OPEN", @"EXAMPLE", @"BEGIN", @"LIFE", @"ALWAY", @"THOSE", @"BOTH", @"PAPER", @"TOGETHER", @"GOT", @"GROUP", @"OFTEN", @"RUN", @"IMPORTANT", @"UNTIL", @"CHILDREN", @"SIDE", @"FEET", @"CAR", @"MILE", @"NIGHT", @"WALK", @"WHITE", @"SEA", @"BEGAN", @"GROW", @"TOOK", @"RIVER", @"FOUR", @"CARY", @"STATE", @"ONCE", @"BOOK", @"HEAR", @"STOP", @"WITHOUT", @"SECOND", @"LATE", @"MISS", @"IDEA", @"ENOUGH", @"EAT", @"FACE", @"WATCH", @"FAR", @"REAL", @"ALMOST", @"LET", @"ABOVE", @"GIRL", @"SOMETIMES", @"MOUNTAIN", @"CUT", @"YOUNG", @"TALK", @"SOON", @"LIST", @"SONG", @"BEING", @"LEAVE", @"FAMILY", @"IT'S", @"AFTERNOON", nil];
    NSString *name2 = @"NameIWantForMyLanguageModelFiles2";
    NSError *err2 = [lmGenerator generateLanguageModelFromArray:words2 withFilesNamed:name2 forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    
    NSDictionary *languageGeneratorResults2 = nil;
    
    lmPath2 = nil;
    dicPath2 = nil;
    
    if([err2 code] == noErr) {
        
        languageGeneratorResults2 = [err2 userInfo];
        
        lmPath2 = [languageGeneratorResults2 objectForKey:@"LMPath"];
        dicPath2 = [languageGeneratorResults2 objectForKey:@"DictionaryPath"];
        
    } else {
        NSLog(@"Error: %@",[err2 localizedDescription]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    
    
    // Turn on remote control event delivery
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
    
    // Set itself as the first responder
    
    [self becomeFirstResponder];
}
- (void)viewWillDisappear:(BOOL)animated {
    
    
    
    // Turn off remote control event delivery
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    
    
    // Resign as first responder
    
    [self resignFirstResponder];
    
    
    
    [super viewWillDisappear:animated];
    
}

-(void)startListening{
    if (!self.pocketsphinxController.isListening){
        if(loggedIn){
            [self.pocketsphinxController startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
        }
        else{
            [self.fliteController say:[NSString stringWithFormat:@"PLEASE LOG IN"] withVoice:self.slt];
        }
    }
}

-(void) currentStory{
    NSLog(@"%@",news[@"data"][newsIndex][@"message"]);
    [self.fliteController say:[NSString stringWithFormat:@"%@",news[@"data"][newsIndex][@"message"]] withVoice:self.slt];
}
-(void) nextStory{
    if (newsIndex < (newsSize-1)){
        newsIndex++;
        NSLog(@"%@",news[@"data"][newsIndex][@"message"]);
        [self.fliteController say:[NSString stringWithFormat:@"%@",news[@"data"][newsIndex][@"message"]] withVoice:self.slt];
    }
    else{
        newsIndex = 0;
        NSLog(@"%@",news[@"data"][newsIndex][@"message"]);
        [self.fliteController say:[NSString stringWithFormat:@"%@",news[@"data"][newsIndex][@"message"]] withVoice:self.slt];
    }
}
-(void) prevStory{
    if (newsIndex > 0){
        newsIndex--;
        NSLog(@"%@",news[@"data"][newsIndex][@"message"]);
        [self.fliteController say:[NSString stringWithFormat:@"%@",news[@"data"][newsIndex][@"message"]] withVoice:self.slt];
    }
    else{
        newsIndex = (newsSize - 1);
        NSLog(@"%@",news[@"data"][newsIndex][@"message"]);
        [self.fliteController say:[NSString stringWithFormat:@"%@",news[@"data"][newsIndex][@"message"]] withVoice:self.slt];
    }
}
-(void) nextFriend{
    if (friendIndex < (friendSize-1)){
        friendIndex++;
        [self.fliteController say:[NSString stringWithFormat:@"%@",friends[@"data"][friendIndex][@"name"]] withVoice:self.slt];
    }
    else{
        friendIndex = 0;
        [self.fliteController say:[NSString stringWithFormat:@"%@",friends[@"data"][friendIndex][@"name"]] withVoice:self.slt];
    }
}
-(void) prevFriend{
    if (friendIndex > 0){
        friendIndex--;
        [self.fliteController say:[NSString stringWithFormat:@"%@",friends[@"data"][friendIndex][@"name"]] withVoice:self.slt];
    }
    else{
        friendIndex = (friendSize - 1);
        [self.fliteController say:[NSString stringWithFormat:@"%@",friends[@"data"][friendIndex][@"name"]] withVoice:self.slt];
    }
}
-(void) friendStatus{
    NSLog(@"%@",friends[@"data"][0][@"id"]);
    [FBRequestConnection startWithGraphPath: [NSString stringWithFormat:@"%@/statuses", friends[@"data"][friendIndex][@"id"]]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              //Handle the result
                              if (!error) {
                                  // Set the status label
                                  if (result[@"data"] && [result[@"data"] count] > 0) {
                                      [self.fliteController say:[NSString stringWithFormat:@"%@",result[@"data"][0][@"message"]] withVoice:self.slt];}}}];
}
-(void)myStatus{
    [FBRequestConnection startWithGraphPath:@"me/statuses"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              //Handle the result
                              if (!error) {
                                  // Set the status label
                                  if (result[@"data"] && [result[@"data"] count] > 0) {
                                      [self.fliteController say:[NSString stringWithFormat:@"%@",result[@"data"][0][@"message"]] withVoice:self.slt];}}}];
}

-(void)postMessage:(NSString *) msg{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            msg, @"message",
                            nil
                            ];
    /* make the API call */
    [FBRequestConnection startWithGraphPath:@"/me/feed"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                          }];
    [self.fliteController say:[NSString stringWithFormat:@"MESSAGE POSTED"] withVoice:self.slt];
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    [self.pocketsphinxController stopListening];
    if (gettingPost){
        [self postMessage: hypothesis];
        gettingPost = false;
    }
    else if ([hypothesis  isEqual: @"CURRENT STORY"]){
        [self currentStory];
    }
    else if ([hypothesis  isEqual: @"NEXT STORY"]){
        [self nextStory];
    }
    else if ([hypothesis  isEqual: @"PREVIOUS STORY"]){
        [self prevStory];
    }
    else if ([hypothesis isEqualToString:(@"CURRENT FRIEND")]){
        [self.fliteController say:[NSString stringWithFormat:@"%@",friends[@"data"][friendIndex][@"name"]] withVoice:self.slt];
    }
    else if ([hypothesis isEqualToString:(@"NEXT FRIEND")]){
        [self nextFriend];
    }
    else if ([hypothesis isEqualToString:(@"PREVIOUS FRIEND")]){
        [self prevFriend];
    }
    else if([hypothesis isEqual: @"MY STATUS"]){
        [self myStatus];
    }
    else if ([hypothesis  isEqual: @"FRIEND STATUS"]){
        [self friendStatus];
    }
    else if ([hypothesis isEqual: @"POST MESSAGE"]){
        gettingPost = true;
        [self.pocketsphinxController startListeningWithLanguageModelAtPath:lmPath2 dictionaryAtPath:dicPath2 acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    }
    else {
        [self.fliteController say:[NSString stringWithFormat:@"NOT A COMMAND"] withVoice:self.slt];
    }
}

- (void) pocketsphinxDidStartCalibration {
    NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
    NSLog(@"Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
    if(gettingPost){
        [self.fliteController say:[NSString stringWithFormat:@"STATE MESSAGE"] withVoice:self.slt];
    }
    else{
        [self.fliteController say:[NSString stringWithFormat:@"STATE COMMAND"] withVoice:self.slt];
    }
    NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
    NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}
- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}

//Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    loggedIn = true;
    [FBRequestConnection startWithGraphPath:@"/me/friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              friends = result;
                              friendSize = (int)[result[@"data"] count];
                          }];
    [FBRequestConnection startWithGraphPath:@"/me/feed"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              news = result;
                              newsSize = (int)[result[@"data"] count];
                          }];
}
// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    loggedIn = false;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        
        
        switch (receivedEvent.subtype) {
                
                
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                
                //Handle event
                [self startListening];
                break;
                
                
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                
                //Handle event
                
                break;
                
                
                
            case UIEventSubtypeRemoteControlNextTrack:
                
                //Handle event
                
                break;
                
                
                
            default:
                
                break;
                
        }
        
    }
    
}

@end
