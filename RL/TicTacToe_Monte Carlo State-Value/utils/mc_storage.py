import json
import os


def save_learning_data(
    Q,
    returns
):

    save_dir = "data/mc_control"

    os.makedirs(
        save_dir,
        exist_ok=True
    )

    serializable_Q = {}

    for state in Q:

        serializable_Q[
            str(state)
        ] = {}

        for action, value in Q[state].items():

            serializable_Q[
                str(state)
            ][
                str(action)
            ] = value

    serializable_returns = {

        str(key): value

        for key, value in returns.items()
    }

    with open(
        f"{save_dir}/Q.json",
        "w"
    ) as f:

        json.dump(
            serializable_Q,
            f,
            indent=4
        )

    with open(
        f"{save_dir}/returns_mc.json",
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