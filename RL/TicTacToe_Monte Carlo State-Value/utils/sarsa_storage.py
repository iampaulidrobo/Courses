import json
import os


def save_learning_data(
    Q
):

    save_dir = "data/sarsa"

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

    with open(
        f"{save_dir}/Q.json",
        "w"
    ) as f:

        json.dump(
            serializable_Q,
            f,
            indent=4
        )

    print(
        f"\nSaved SARSA data to {save_dir}\n"
    )