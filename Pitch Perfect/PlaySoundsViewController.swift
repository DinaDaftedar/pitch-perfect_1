//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Dina Daftedar on 5/27/15.
//  Copyright (c) 2015 Dina Daftedar. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

///To play back the audio sound recorded by the RecordSoundsViewController
class PlaySoundsViewController: UIViewController {
   
    ///an audio player variable
    var audioPlayer:AVAudioPlayer!
    ///an audio player variable for the echo effect
    var echoAudioPlayer:AVAudioPlayer!
    ///a variable to hold the received audio from the RecordSoundsViewController
    var receivedAudio:RecordedAudio!
    ///a vriable for the audio engine
    var audioEngine:AVAudioEngine!
    ///a variable to hold the audio file
    var audioFile:AVAudioFile!
    ///a variable to hold the array of audio players
    var reverbPlayers:[AVAudioPlayer]!
    

    ///a function to override the viewDidLoad of the UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        //initialize the audio player and adjust its settings
        var error:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: &error)
        audioPlayer.enableRate = true
        audioPlayer.volume = 1.0
        //initialize the audio engine with the recorded audio
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        //initialize the echo audio player with the recorded audio file
        echoAudioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: &error)
        //reverb array players
        reverbPlayers = []
    }

    ///a function to stop all of the sounds playing by stopping all of the audio players and the audio engine too
    func stopAllSounds() {
        //stop main player
        audioPlayer.stop()
        //stop reverb players
        if (reverbPlayers != []) {
            let N:Int = 10
            for i in 0...N {
                reverbPlayers[i].stop()
            }
        }
        //stop echo player
        echoAudioPlayer.stop()
        //stop audioEngine
        audioEngine.stop()
        audioEngine.reset()
    }

    ///a function to play back the recorded audio with a differnt pitch. It takes the pitch value as a float.
    func playAudioWithVariablePitch(pitch: Float) {
        //declare and initialize a player node
        var pitchPlayer = AVAudioPlayerNode()
        //attach the node to the audio engine
        audioEngine.attachNode(pitchPlayer)
        //declae and initialize a unit time pitch variable
        var timePitch = AVAudioUnitTimePitch()
        //set the pitch to the value passed in through the function
        timePitch.pitch = pitch
        //attach the time pitch node to the audio engine
        audioEngine.attachNode(timePitch)
        //connect the pitch player to the time pitch
        audioEngine.connect(pitchPlayer, to: timePitch, format: nil)
        //connect the time pitch to the audio engine's output
        audioEngine.connect(timePitch, to: audioEngine.outputNode, format:nil)
        //schedule the audio file to be played
        pitchPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        //playback the audio file after changing its pitch
        pitchPlayer.play()
    }

    ///an action invoked to play back the audio with DarthVader effect. The action is invoked after clicking the button with the Darthvader image on
    @IBAction func playDarthvaderAudio(sender: UIButton) {
        //call the stopAllSounds() function to stop all of the audio players
        stopAllSounds()
        //call the playAudioWithVariablePitch() function with pitch = -1000 to match the Darth vader effect
        playAudioWithVariablePitch(-1000)
    }
    
    ///an action invoked to play back the audio with Chipmunk effect. The action is invoked after clicking the button with the Chipmunk image on
    @IBAction func playChipmunkAudio(sender: UIButton) {
        //call the stopAllSounds() function to stop all of the audio players
        stopAllSounds()
        //call the playAudioWithVariablePitch() function with pitch = 1000 to match the Chipmuck effect
        playAudioWithVariablePitch(1000)
    }
    
    ///a function to set the audio player's setting, play rate (speed) of playback of the recorded audio, current time and play the audio
    func playerSetup(playRate: Float, ctime: NSTimeInterval) {
        //set the audio palyer's rate to the play rate passed into the function
        audioPlayer.rate = playRate
        //set the current play back time to to the current time passed into the function
        audioPlayer.currentTime = ctime
        //play the audio file
        audioPlayer.play()
    }

    ///an action to play back the audio at a slower speed.  The action is invoked after clicking the butto with the snail image on
    @IBAction func playSlowSound(sender: UIButton) {
        //call the stopAllSounds() function to stop all of the audio players
        stopAllSounds()
        //call the speedSettings function and set the play rate to 0.5
        playerSetup(0.5,ctime: 0.0)
    }
    
    ///an action to play back the audio at a faster speed.  The action is invoked after clicking the butto with the rabbit image on
    @IBAction func playFastSound(sender: UIButton) {
        //call the stopAllSounds() function to stop all of the audio players
        stopAllSounds()
        //call the speedSettings function and set the play rate to 1.5
        playerSetup(1.5, ctime: 0.0)
    }
    
    ///an action invoked by clicking the Stop button to stop all of the sounds playing
    @IBAction func stopAnySound(sender: UIButton) {
        //call the stopAllSounds() function to stop all of the audio players
        stopAllSounds()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    ///an action invoked by clicking the ECHO button to add the echo effect to the play back sound
    @IBAction func playEcho(sender: UIButton) {
        //call the stopAllSounds() function to stop all of the audio players
        stopAllSounds()
        playerSetup(1.0, ctime: 0.0)
        //setup the echo audio player and play back the audio with a delay = 0.2ms
        let delay:NSTimeInterval = 0.2//100ms
        var playtime:NSTimeInterval
        playtime = echoAudioPlayer.deviceCurrentTime + delay
        echoAudioPlayer.stop()
        echoAudioPlayer.currentTime = 0
        echoAudioPlayer.volume = 0.8;
        echoAudioPlayer.playAtTime(playtime)
    }
    
    ///an action invoked by clikcing the REVERB button to add the revrb effect to the play back sound
    @IBAction func playReverb(sender: UIButton) {
        //call the stopAllSounds() function to stop all of the audio players
        stopAllSounds()
        let N:Int = 10
        let delay:NSTimeInterval = 0.02
        //loop over the N audio players
        for i in 0...N {
            //initialize each audio player and pass the recorded audio file as an input
            reverbPlayers.append(AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil))
            //update the delay  = delay * the sequence of the audio player
            var curDelay:NSTimeInterval = delay*NSTimeInterval(i)
            var player:AVAudioPlayer = reverbPlayers[i]
            //M_E is e=2.718...
            //dividing N by 2 made it sound ok for the case N=10
            var exponent:Double = -Double(i)/Double(N/2)
            var volume = Float(pow(Double(M_E), exponent))
            player.volume = volume
            //play back the audio
            player.playAtTime(player.deviceCurrentTime + curDelay)
        }
    }

}
