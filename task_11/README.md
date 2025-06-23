# ASR - Automatic Speech Recognition

A Ruby-based automatic speech recognition application powered by OpenAI's Whisper-1 model.

## Features

🎙️ **Audio Transcription** - Convert speech to text using OpenAI Whisper-1  
📁 **File Analysis** - Detailed file path information and validation  
🌍 **Translation** - Translate non-English audio to English  
⏰ **Timestamps** - Word-level and segment-level timestamps  
🎵 **Multi-format Support** - Supports all major audio formats  
🔧 **Interactive Interface** - User-friendly console application  

## Setup

### 1. Requirements

- Ruby (tested with Ruby 3.3.0)
- OpenAI API key

### 2. Configuration

1. **Copy the environment template:**
   ```bash
   cp env.example .env
   ```

2. **Add your OpenAI API key to `.env`:**
   ```bash
   # Edit .env file
   OPENAI_API_KEY=your_actual_api_key_here
   ```

3. **Optional: Enable debug mode:**
   ```bash
   # Add to .env file
   DEBUG=true
   ```

### 3. Supported Audio Formats

The application supports the following audio formats:
- MP3 (`.mp3`)
- MP4 (`.mp4`)
- WAV (`.wav`)
- M4A (`.m4a`)
- FLAC (`.flac`)
- OGG (`.ogg`)
- WebM (`.webm`)
- AAC (`.aac`)
- Opus (`.opus`)
- AMR (`.amr`)
- 3GP (`.3gp`)
- MPEG (`.mpeg`, `.mpga`)

## Usage

### Interactive Mode

Run the main application:
```bash
./asr.rb
```

### Command Line Mode

Process a specific file:
```bash
./asr.rb /path/to/audio/file.mp3
```

### Demo Mode

Process the included demo file:
```bash
./asr.rb
# Then type: demo
```

## Available Commands

- **Enter file path** - Show file info and transcribe if it's an audio file
- **demo** - Process the included demo.mp3 file
- **help** - Show help information
- **quit** - Exit the application

## Transcription Options

After basic transcription, you can choose advanced options:

- **t** - Transcribe with word-level timestamps
- **v** - Verbose transcription with segments
- **r** - Translate to English
- **s** - Skip advanced options

## Examples

### Basic Transcription
```ruby
require_relative 'lib/api_clients/whisper_client'

client = WhisperClient.new
result = client.transcribe('audio.mp3')
puts result['text']
```

### With Timestamps
```ruby
result = client.transcribe_with_timestamps('audio.mp3')
WhisperClient.pretty_print_result(result)
```

### Translation
```ruby
result = client.translate('spanish_audio.mp3')
puts result['text']  # Translated to English
```

### File Information
```ruby
info = client.file_info('audio.mp3')
puts "Size: #{info[:size_mb]} MB"
puts "Supported: #{info[:supported]}"
```

## Transcription Services

### Run Demo Transcription Service
```bash
ruby lib/transcriptors/whisper_transcriptor.rb
```

### Interactive Transcription Mode
```bash
ruby lib/transcriptors/whisper_transcriptor.rb
# Choose option 2 for interactive mode
```

## File Structure

```
task_11/
├── asr.rb                    # Main ASR application
├── demo.mp3                  # Sample audio file
├── env.example               # Environment template
├── .env                      # Your API key (create this)
├── .gitignore               # Git ignore rules
├── README.md                # This file
└── lib/
    ├── api_clients/         # API client classes
    │   ├── whisper_client.rb  # OpenAI Whisper API client
    │   └── openai_client.rb   # OpenAI Chat API client
    ├── transcriptors/       # Transcription services
    │   └── whisper_transcriptor.rb # Whisper transcription service
    ├── env_loader.rb        # Environment file loader
    ├── file_info_printer.rb # File information display
    └── transcription_printer.rb # Transcription results display
```

## Error Handling

The application handles various error scenarios:

- **Missing API key** - Clear instructions to set up .env file
- **Unsupported file formats** - Lists supported formats
- **File size limits** - Maximum 25MB per file
- **Network errors** - Graceful handling of API issues
- **File permissions** - Readable file validation

## Security

- The `.env` file is automatically ignored by git
- API keys are never logged or displayed
- File handles are properly closed after use

## Troubleshooting

### "cannot load such file" errors
Make sure you're running from the task_11 directory:
```bash
cd task_11
./asr.rb
```

### "API key required" errors
1. Check if `.env` file exists
2. Verify OPENAI_API_KEY is set correctly
3. Ensure no extra spaces or quotes in the key

### "File not found" errors
- Use absolute paths or relative paths from task_11 directory
- Check file permissions
- Verify file exists and is readable

### Network/API errors
- Check internet connection
- Verify API key is valid and has credits
- Check OpenAI API status

## License

This project is for educational purposes. OpenAI API usage is subject to OpenAI's terms of service. 