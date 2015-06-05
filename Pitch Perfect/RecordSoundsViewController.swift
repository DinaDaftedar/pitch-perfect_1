//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Dina Daftedar on 5/24/15.
//  Copyright (c) 2015 Dina Daftedar. All rights reserved.
//

import UIKit
import AVFoundation

///To record your audio and save it to be played back with different tones
class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    //IBOutlet for the error message label
    @IBOutlet weak var errorMessage: UILabel!
    //IBOutlet for the stop button
    @IBOutlet weak var stopButton: UIButton!
    //IBOutlet for the record label
    @IBOutlet weak var recordLabel: UILabel!
    //IBOutlet for the record button
    @IBOutlet weak var recordButton: UIButton!
    //IBOutlet for the pause button
    @IBOutlet weak var pauseButton: UIButton!
    //variable for the AVAudio recorder
    var audioRecorder:AVAudioRecorder!
    //variable for the recorded audio
    var recordedAudio:RecordedAudio!
    
    ///a function to override the default viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        recordLabel.text = "Tap to Record"
    }

    ///a function to override the default viewWillAppear()
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        resetControls()
    }
    
    ///To reset the main landing page's content
    ///Like hiding and showing buttons, changing a label's text
    ///
    ///:returns: nil
    func resetControls() {
        //hide the stop and pause buttons and show the 'Tap to Record' label
        stopButton.hidden=true
        pauseButton.hidden=true
        recordButton.enabled=true
        recordLabel.text = "Tap to Record"
        errorMessage.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///An action invoked by the Stop button, it stops the audio recorder and closes the audio session
    ///
    ///:returns: nil
    @IBAction func stopRecording(sender: UIButton) {
        resetControls()
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }

    ///An action invoked by the Pause button, it pauses the audio recorder
    ///
    ///:returns: nil
    @IBAction func pauseRecording(sender: UIButton) {
        resetControls()
        audioRecorder.pause()
    }

    ///An action invoked after the Stop button is released
    ///
    ///:returns: nil
    @IBAction func recordFinished(sender: UIButton) {
        println("finished recordAudio")
    }
    
    ///An action invoked by the Record (Microphone) button, it saves the audio with a special naming format. It initializes an audio session and starts recording the audio
    ///
    ///:returns: nil
    @IBAction func recordAudio(sender: UIButton) {
        println("in recordAudio")
        //show the pause and stop button and update the label to indicate the recording is in progress
        recordLabel.text = "Recording in progress..."
        stopButton.hidden=false
        recordButton.enabled=false
        pauseButton.hidden=false
        //set the directory path
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as!  String
        //set the audio file name date-time.wav format
        var currentDateTime = NSDate()
        var formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        var recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        var pathArray = [dirPath, recordingName]
        var filePath = NSURL.fileURLWithPathComponents(pathArray)
        //declare and initialize a play and record audio session
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        //setup the audio recorder and start recording
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
  
    ///A function provided by the AVAudioRecorderDelegate that is invoke once the recording is finished. If successful the performSegueWithIdentifier is called otherwise in case of an error, an error message is displayed to inform the user
    ///
    ///:returns: nil
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (flag) {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url,title: recorder.url.lastPathComponent!)
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            println("Error recording")
            errorMessage.hidden = false
            recordButton.enabled = true
            stopButton.hidden = true
        }
    }
  
    ///A function that prepares for the Segue
    ///
    ///:returns: nil
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundVC.receivedAudio = data
        }
    }
    
}

