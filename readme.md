# Voice Generator for EdgeTX

This voice generator has been developed specifically for running on MacOS and utilizing a free
account from ElevenLabs.  Instructions on how to set up an account and get your api key can be
found [here](https://docs.elevenlabs.io/api-reference/quick-start/introduction).  

## Usage

* make sure ruby version 3.0 or higher is installed
* run `bundle install` to get all the dependencies
* copy the `env_template` file to `.env` and fill in your API key 
* run `./generate_voices voices` to get a list of all available voices
* run `./generate_voices generate --voice-id <voice id> --csv ./example.csv --destination "./sounds/mimi" `

## The CSV file

The format of this CSV file is based on the format used by the `edgetx-sdcard-sounds` project 
[here](https://github.com/EdgeTX/edgetx-sdcard-sounds/tree/main/voices).  You can use any of those csv files as the 
base.  I typically have a `voices.csv` file that I've copied from that repo and then added custom phrases to it.

Feedback is welcome along with PRs.
