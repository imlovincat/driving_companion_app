int getSharpSpeedValue(String level) {
  if (level == "a1") return 6;
  else if (level == "a2") return 8;
  else if (level == "a3") return 10;
  else if (level == "a4") return 12;
  else if (level == "a5") return 14;
  else if (level == "d1") return 7;
  else if (level == "d2") return 10;
  else if (level == "d3") return 13;
  else if (level == "d4") return 16;
  else if (level == "d5") return 19;
  return 0;
}