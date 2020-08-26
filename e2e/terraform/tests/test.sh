#!/bin/bash
# test the profiles by running Terraform plans and extracting the
# plans into JSON for comparison
set -eu

command -v jq > /dev/null || (echo "jq required"; exit 1 )
command -v terraform > /dev/null || (echo "terraform required"; exit 1 )

tempdir=$(mktemp -d)

plan() {
    vars_file="$1"
    out_file="$2"
    terraform plan --var-file="$vars_file" -out="$out_file" > /dev/null
}

# read the plan file to extract the bits we care about into JSON, and
# then compare this to the expected file.
check() {
    plan_file="$1"
    expected_file="$2"

    got=$(terraform show -json "$plan_file" \
        | jq --sort-keys --raw-output '
([.resource_changes[]
    | select(.name == "upload_configs")
    | select(.change.actions[0] == "create")]
    | reduce .[] as $i ({};
        .[($i.module_address|ltrimstr("module."))] =
        .[($i.module_address|ltrimstr("module."))] + [$i.index])
) as $configs |
([.resource_changes[]
    | select(.name == "install_nomad_version")]
    | reduce .[] as $i ({};
        .[($i.module_address|ltrimstr("module."))] =
        .[($i.module_address|ltrimstr("module."))]
        + $i.change.after.triggers.nomad_version)
) as $version |
([.resource_changes[]
    | select(.name == "install_nomad_sha")]
    | reduce .[] as $i ({};
        .[($i.module_address|ltrimstr("module."))] =
        .[($i.module_address|ltrimstr("module."))]
        + $i.change.after.triggers.nomad_sha)
) as $sha |
([.resource_changes[]
    | select(.name == "install_nomad_binary")]
    | reduce .[] as $i ({};
        .[($i.module_address|ltrimstr("module."))] =
        .[($i.module_address|ltrimstr("module."))]
        + $i.change.after.triggers.nomad_binary_sha)
) as $binary |
{
    configs: $configs,
    installed_version: $version,
    installed_sha: $sha,
    installed_binary: $binary
}')

    diff "$expected_file" <(echo "$got")

}

run() {
    echo -n "testing $1-test.tfvars... "
    plan "$1-test.tfvars" "${tempdir}/$1.plan"
    check "${tempdir}/$1.plan" "$1-expected.json"
    echo "ok!"
}

run 1
run 2
run 3
run 4
run 5
run 6
run 7

rm -r "${tempdir}"
