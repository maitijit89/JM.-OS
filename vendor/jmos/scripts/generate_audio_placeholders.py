import os

# Minimal valid silent Ogg Vorbis binary pattern (108 bytes)
TINY_OGG_HEX = (
    "4f67675300020000000000000000a4a1c233000000006de0fde6011e01766f72626973000000000244ac"
    "0000000000000000000000e803000000000000b8014f67675300000000000000000000a4a1c2330100"
    "0000a47879fd012d03766f726269731b00000063726561746564206279206d696e696d616c206f6767"
    "20736372697074010000001e0000005449544c453d4d696e696d616c2053696c656e7420506c616365"
    "686f6c646572014f67675300000000000000000000a4a1c23302000000cfdcdbb901014f6767530004"
    "0000000000000000a4a1c233030000003cf5fec60100"
)

AUDIO_FILES = [
    r"vendor\jmos\prebuilt\common\media\audio\ui\PowerOn.ogg",
    r"vendor\jmos\prebuilt\common\media\audio\ui\Lock.ogg",
    r"vendor\jmos\prebuilt\common\media\audio\ui\Unlock.ogg",
    r"vendor\jmos\prebuilt\common\media\audio\ui\ChargingStarted.ogg",
    r"vendor\jmos\prebuilt\common\media\audio\ui\LowBattery.ogg",
    r"vendor\jmos\prebuilt\common\media\audio\ringtones\JM_Ringtone.ogg",
    r"vendor\jmos\prebuilt\common\media\audio\notifications\JM_Notification.ogg",
    r"vendor\jmos\prebuilt\common\media\audio\alarms\JM_Alarm.ogg"
]

def main():
    base_dir = r"e:\Dj-OS"
    binary_data = bytes.fromhex(TINY_OGG_HEX)
    
    print("Generating system audio placeholder files...")
    
    for rel_path in AUDIO_FILES:
        full_path = os.path.join(base_dir, rel_path)
        dir_name = os.path.dirname(full_path)
        
        # Ensure directories exist
        if not os.path.exists(dir_name):
            os.makedirs(dir_name)
            
        # Write binary file
        print(f"Writing: {rel_path}")
        with open(full_path, 'wb') as f:
            f.write(binary_data)
            
    print("System audio placeholders generated successfully!")

if __name__ == "__main__":
    main()
