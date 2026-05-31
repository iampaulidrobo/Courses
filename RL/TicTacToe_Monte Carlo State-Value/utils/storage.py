import json
import os


def save_learning_data(
    V,
    returns
):

    save_dir = "data/mc_prediction"

    os.makedirs(
        save_dir,
        exist_ok=True
    )

    serializable_V = {

        str(k): v

        for k, v in V.items()
    }

    serializable_returns = {

        str(k): v

        for k, v in returns.items()
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

    with open(
        f"{save_dir}/returns.json",
        "w"
    ) as f:

        json.dump(
            serializable_returns,
            f,
            indent=4
        )

    print(
        f"\nSaved data to {save_dir}\n"
    )