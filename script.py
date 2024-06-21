import argparse
import os
import subprocess

PATH = "C:/Users/sterben/.vscode/extensions/sterben.fpga-support-0.2.6/lib/com/Hardware/"

def get_module_name_from_path(file_path):
    return os.path.splitext(os.path.basename(file_path))[0]

def create_verilog_module(file_path):
    module_name = get_module_name_from_path(file_path)

    # Verilog module template
    verilog_template = f"""\
module {module_name} (
    input wire clock,
    input wire reset
);

// TODO: Add your module implementation here

endmodule
"""

    # Create a file with the given path and write the template to it
    with open(PATH + file_path, 'w') as file:
        file.write(verilog_template)
    
    print(f"Verilog module '{module_name}' created successfully in file '{file_path}'.")

def rename_verilog_file(old_path, new_path):
    if os.path.exists(PATH + old_path):
        os.rename(PATH + old_path, PATH + new_path)
        print(f"Renamed '{old_path}' to '{new_path}'.")
    else:
        print(f"Error: File '{old_path}' does not exist.")

def delete_verilog_file(file_path):
    if os.path.exists(PATH + file_path):
        os.remove(PATH + file_path)
        print(f"Deleted file '{file_path}'.")
    else:
        print(f"Error: File '{file_path}' does not exist.")

def push_to_github(commit_message):
    try:
        # Add file to git
        subprocess.run(["git", "add ."], check=True)
        # Commit changes
        subprocess.run(["git", "commit", "-m", commit_message], check=True)
        # Push to GitHub
        subprocess.run(["git", "push"], check=True)
        print(f"Successfully pushed to GitHub.")
    except subprocess.CalledProcessError as e:
        print(f"Error during git operation: {e}")

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description="Create, rename, delete a Verilog module file, or push to GitHub.")
    parser.add_argument('-mk', '--module', type=str, help="The path of the Verilog module file to create.")
    parser.add_argument('-mv', '--move', nargs=2, metavar=('OLD_PATH', 'NEW_PATH'), help="Rename a Verilog module file.")
    parser.add_argument('-rm', '--remove', type=str, help="Delete a Verilog module file.")
    parser.add_argument('-push', '--push', nargs=1, metavar=('COMMIT_MESSAGE'), help="Push a file to GitHub.")

    # Parse command-line arguments
    args = parser.parse_args()

    # Perform the requested action
    if args.module:
        create_verilog_module(args.module)
    elif args.move:
        old_path, new_path = args.move
        rename_verilog_file(old_path, new_path)
    elif args.remove:
        delete_verilog_file(args.remove)
    elif args.push:
        file_path, repo_url, commit_message = args.push
        push_to_github(file_path, repo_url, commit_message)
    else:
        print("No valid arguments provided. Use -h for help.")

if __name__ == "__main__":
    main()
