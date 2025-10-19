# Load the input and output messages
message_in = '33333333 abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789 !@#$%^&*()_+-=~`;:"<>./?'
# Read the output file
with open("out_char.txt", "r") as f:
    message_out = f.read().strip()

print(f"-------------Comparing Result--------------------")
print(f"Correct message:{message_in}")
print(f"Output message :{message_out}")
print(f"------------------------------------------------")
