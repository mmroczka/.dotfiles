export const command =
  'A=$(command -v aerospace || echo /usr/local/bin/aerospace); ' +
  'focused=$($A list-workspaces --focused); ' +
  'occupied=$($A list-windows --all --format "%{workspace}" | sort -u | tr "\\n" ","); ' +
  'layout=$($A list-windows --workspace focused --format "%{workspace-root-container-layout}" | head -1); ' +
  'maximized=$($A list-windows --focused --format "%{window-is-fullscreen}" 2>/dev/null); ' +
  'echo "$focused|$occupied|$layout|$maximized"';

export const refreshFrequency = 10000;

const WORKSPACES = [1, 2, 3, 4, 5];

export const className = {
  pointerEvents: "none",
  position: "fixed",
  top: 0,
  left: 0,
  width: 40,
  height: "100%",
};

export const render = ({ output }) => {
  const parts = (output || "").trim().split("|");
  const focused = parseInt(parts[0], 10);
  const occupied = (parts[1] || "").split(",").filter(Boolean).map(Number);
  const layout = (parts[2] || "").trim();
  const layoutLabel = layout.includes("accordion") ? "A" : layout.includes("tiles") ? "T" : "";
  const isMaximized = (parts[3] || "").trim() === "true";

  const container = {
    position: "fixed",
    top: 0,
    left: 0,
    width: 40,
    height: "100%",
    background: "#1a1a1a",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "center",
    gap: 16,
    zIndex: 1,
  };

  const dot = (active, hasWindows) => ({
    width: 12,
    height: 12,
    borderRadius: "50%",
    border: active
      ? "2px solid rgba(255,255,255,0.9)"
      : hasWindows
        ? "2px solid rgba(255,255,255,0.4)"
        : "2px solid rgba(255,255,255,0.15)",
    background: active ? "rgba(255,255,255,0.9)" : "transparent",
    transition: "all 0.15s ease",
  });

  const label = {
    color: "rgba(255,255,255,0.5)",
    fontSize: 11,
    fontFamily: "-apple-system, sans-serif",
    fontWeight: 600,
    marginTop: 8,
  };

  const maximizedLabel = {
    color: "#ff3333",
    fontSize: 16,
    fontFamily: "-apple-system, sans-serif",
    fontWeight: 700,
    marginBottom: 8,
  };

  return (
    <div style={container}>
      {isMaximized && <div style={maximizedLabel}>M</div>}
      {WORKSPACES.map((ws) => (
        <div key={ws} style={dot(ws === focused, occupied.includes(ws))} />
      ))}
      {layoutLabel && <div style={label}>{layoutLabel}</div>}
    </div>
  );
};
