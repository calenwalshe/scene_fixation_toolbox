"""Render the aggregate fixation-duration histograms shipped with this repo."""
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from scipy.io import loadmat

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = Path(__file__).with_name("fixation-duration-distributions.png")
EXPERIMENTS = [
    ("Experiment 1", "100_60", ROOT / "_data/h_fixdur_exp1.mat"),
    ("Experiment 2", "100_20", ROOT / "_data/h_fixdur_exp2.mat"),
]
CONDITIONS = [
    (1, "No change", "#0072B2"),
    (2, "Luminance up", "#D55E00"),
    (3, "Luminance down", "#009E73"),
]


def main() -> None:
    plt.rcParams.update({
        "font.family": "DejaVu Sans",
        "font.size": 10,
        "axes.titleweight": "semibold",
        "axes.edgecolor": "#C8D0D8",
        "axes.labelcolor": "#344054",
        "xtick.color": "#475467",
        "ytick.color": "#475467",
        "text.color": "#1D2939",
        "figure.facecolor": "white",
        "axes.facecolor": "white",
        "savefig.facecolor": "white",
    })

    fig, axes = plt.subplots(1, 2, figsize=(12, 4.8), sharey=True)
    fig.subplots_adjust(left=0.08, right=0.99, bottom=0.18, top=0.76, wspace=0.12)
    fig.suptitle("Observed fixation-duration distributions", x=0.08, y=0.97,
                 ha="left", fontsize=19, fontweight="bold")
    fig.text(0.08, 0.88, "Aggregated observations  ·  60 ms bins  ·  proportions within condition",
             ha="left", fontsize=10, color="#667085")

    for ax, (experiment, code, path) in zip(axes, EXPERIMENTS):
        rows = np.asarray(loadmat(path, squeeze_me=True)["human_data"])
        for condition_id, label, color in CONDITIONS:
            values = rows[rows[:, 0] == condition_id]
            ax.plot(values[:, 2], values[:, 1] * 100, color=color, label=label,
                    linewidth=2.5, marker="o", markersize=4.2,
                    markeredgewidth=0, solid_capstyle="round")
        ax.set_title(f"{experiment}  ·  {code}", loc="left", pad=14, fontsize=12)
        ax.set_xlim(0, 1200)
        ax.set_ylim(0, 30)
        ax.set_xticks(np.arange(0, 1201, 200))
        ax.set_yticks(np.arange(0, 31, 5))
        ax.set_xlabel("Fixation-duration bin centre (ms)", labelpad=9)
        ax.grid(axis="y", color="#E9EEF3", linewidth=0.9)
        ax.grid(axis="x", visible=False)
        ax.spines[["top", "right"]].set_visible(False)
        ax.spines[["left", "bottom"]].set_color("#D0D5DD")
        ax.tick_params(length=0, pad=7)
    axes[0].set_ylabel("Observations in bin (%)", labelpad=10)
    axes[1].tick_params(labelleft=False)

    handles, labels = axes[0].get_legend_handles_labels()
    fig.legend(handles, labels, loc="upper right", bbox_to_anchor=(0.99, 0.90),
               frameon=False, ncol=3, handlelength=1.8, columnspacing=1.5)
    fig.text(0.08, 0.045,
             "The source files contain aggregate proportions; points are bin centres, not raw observations.",
             fontsize=8.5, color="#667085")
    fig.savefig(OUTPUT, dpi=180)
    print(OUTPUT)


if __name__ == "__main__":
    main()
