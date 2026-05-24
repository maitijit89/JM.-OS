import os
import zipfile

def main():
    bootanim_dir = r"e:\Dj-OS\vendor\jmos\prebuilt\common\media\bootanimation"
    output_zip = r"e:\Dj-OS\vendor\jmos\prebuilt\common\media\bootanimation.zip"
    
    print(f"Zipping bootanimation from {bootanim_dir} to {output_zip}...")
    
    # Files/Dirs to include
    targets = [
        ("desc.txt", "desc.txt"),
        ("part0/00001.png", "part0/00001.png"),
        ("part1/00001.png", "part1/00001.png")
    ]
    
    with zipfile.ZipFile(output_zip, 'w', zipfile.ZIP_STORED) as zip_file:
        for local_rel_path, zip_path in targets:
            full_path = os.path.join(bootanim_dir, local_rel_path)
            if os.path.exists(full_path):
                print(f"Adding: {local_rel_path} -> {zip_path}")
                zip_file.write(full_path, zip_path)
            else:
                print(f"WARNING: File not found: {full_path}")
                
    print("Zipping complete! bootanimation.zip created successfully with STORED compression.")

if __name__ == "__main__":
    main()
