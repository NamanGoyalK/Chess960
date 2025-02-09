import chess
import numpy as np


# Function to convert a 10-bit binary sequence to a Chess960 position
def encode_to_chess960(binary_data):
    if len(binary_data) != 10:
        raise ValueError(
            "Binary data must be exactly 10 bits to represent a Chess960 position."
        )

    # Convert binary data to integer (0-959 range)
    position_index = int(binary_data, 2)

    # Get the corresponding Chess960 board position
    board = chess.Board(chess960=True)
    board.set_chess960_pos(position_index)

    return board, position_index


# Function to decode a Chess960 board back to binary
def decode_from_chess960(board):
    if not board.chess960:
        raise ValueError("The provided board is not a Chess960 board.")

    # Get the Chess960 position index
    position_index = board.chess960_pos()

    # Convert the position index back to a 10-bit binary sequence
    binary_data = format(position_index, "010b")

    return binary_data


# Example of generating a random 10-bit binary sequence (as a string)
binary_sequence = "".join(np.random.choice(["0", "1"], size=10))
print(f"Random 10-bit sequence: {binary_sequence}")

# Encode this binary sequence into a Chess960 board
chess_board, pos_index = encode_to_chess960(binary_sequence)
print(f"Chess960 Position Index: {pos_index}")
print(chess_board)

# Decode the Chess960 board back to the original binary sequence
decoded_binary = decode_from_chess960(chess_board)
print(f"Decoded Binary Sequence: {decoded_binary}")

# Verify that the decoded binary sequence matches the original
assert (
    binary_sequence == decoded_binary
), "The decoded binary does not match the original!"
print("Encoding and decoding were successful!")
