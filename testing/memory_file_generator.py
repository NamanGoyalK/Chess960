import chess


def generate_positions_mem():
    with open("chess960_positions.mem", "w") as f:
        for i in range(960):
            board = chess.Board(chess960=True)
            board.set_chess960_pos(i)

            # Convert FEN to 64-bit representation
            fen = board.fen().split()[0]
            # This is simplified - you'd need to convert FEN to actual 64-bit encoding
            # For now, using hash as placeholder
            hash_val = hash(fen) & 0xFFFFFFFFFFFFFFFF
            f.write(f"{hash_val:016X}\n")


generate_positions_mem()
