{pkgs, ...}:
pkgs.writers.writePython3Bin "convert-scheme" {
  libraries = with pkgs.python311Packages; [pyyaml];
  flakeIgnore = ["E302" "E305" "E501"];
} ''
  import argparse
  import yaml
  import json

  def yaml_to_json(yaml_file, json_file):
      with open(yaml_file, 'r') as yml_file:
          data = yaml.load(yml_file, Loader=yaml.FullLoader)

      with open(json_file, 'w') as json_file:
          json.dump(data, json_file, indent=4)

  if __name__ == "__main__":
      parser = argparse.ArgumentParser(description="Convert YAML to JSON")
      parser.add_argument("input", help="Path to the input YAML file")
      parser.add_argument("output", help="Path to the output JSON file")
      args = parser.parse_args()

      yaml_to_json(args.input, args.output)
''
