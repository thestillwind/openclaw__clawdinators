const pattern =
  // Matches ANSI escape sequences.
  // Source: minimal pattern to strip CSI and OSC sequences.
  /[\u001B\u009B][[\]()#;?]*(?:[0-9]{1,4}(?:;[0-9]{0,4})*)?[0-9A-ORZcf-nqry=><]/g;

export default function stripAnsi(input) {
  if (typeof input !== "string") return input;
  return input.replace(pattern, "");
}
