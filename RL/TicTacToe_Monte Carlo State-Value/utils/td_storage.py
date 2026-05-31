import json
import os


def save_learning_data(
    V
):

    save_dir = "data/td0"

    os.makedirs(
        save_dir,
        exist_ok=True
    )

    serializable_V = {

        str(state): value

        for state, value in V.items()
    }

    with open(
        f"{save_dir}/V.json",
        "w"
    ) as f:

        json.dump(
            serializable_V,
            f,
            indent=4
        )

    print(
        f"\nSaved TD(0) data to {save_dir}\n"
    )