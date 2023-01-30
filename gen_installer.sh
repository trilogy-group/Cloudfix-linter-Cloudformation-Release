#!/bin/bash
cat > install.sh <<EOF1
#!/bin/bash

if [[ "\$OSTYPE" =~ ^darwin ]]; then
  OS=darwin
  brew install wget
  brew install cfn-lint
else
  OS=linux
  pip install cfn-lint
fi

Arch=\$(uname -m)

if [[ "\$Arch" == "x86_64" || "\$Arch" == "amd64" ]]; then
    ARCH=amd64
elif [[ "\$Arch" == "aarch64" || "\$Arch" == "arm64" ]]; then
    ARCH=arm64
elif [[ "\$Arch" == "i686" || "\$Arch" == "i386" ]]; then
    ARCH=386
elif [ "\$Arch" = "armhf" ]; then
    ARCH=arm
else 
    echo "Unsupported platform"
    exit 1
fi

PLATFORM=\$OS
PLATFORM+="_"
PLATFORM+=\$ARCH

mkdir -p cloudfix-linter
cd cloudfix-linter

VERSION_TAG=$(git describe --tags --abbrev=0)
# Install cloudfix-linter-cloudformation
echo "Installing cloudfix-linter-cloudformation"
file_name=cloudfix-linter-cloudformation_\${PLATFORM}
(wget https://github.com/trilogy-group/cloudfix-linter-cloudformation/releases/tag/\${VERSION_TAG}/download/\${file_name} -O \${file_name} --no-check-certificate \
  && mv \${file_name} cloudfix-linter-cloudformation)
# Setting alias for cloudfix-linter so that it can be used via command line without referencing the binary path
path=\$(pwd)
path+="/cloudfix-linter-cloudformation"
alias cloudfix-linter=\$path
chmod +x cloudfix-linter-cloudformation

# Python file for CFN-Lint
echo "Downloading required python files"
(wget https://github.com/trilogy-group/cloudfix-linter-cloudformation/releases/tag/\${VERSION_TAG}/download/mynewrule.py -O mynewrule.py --no-check-certificate )
EOF1

cat >install.ps1 <<EOF2
# Finding OS architecture

\$is64Bit = Test-Path 'Env:ProgramFiles(x86)'
\$PLATFORM="Unidentified Operating System"
# Identifying the Operting system Architecture
if(\$is64Bit){
    \$PLATFORM="windows_amd64"
}else {
    \$PLATFORM="windows_386"
}


\$OUT_PATH= \$(Get-Item .).FullName+"\cloudfix-linter\"
if (-Not (Get-Item \$OUT_PATH)) { New-Item -Path \$OUT_PATH -ItemType Directory }

\$VERSION_TAG=$(git describe --tags --abbrev=0)
# Install cloudfix-linter
Write-Output "Installing cloudfix-linter-cloudformation........"
\$OUT_PATH_CFT=\$OUT_PATH+"cloudfix-linter-cloudformation.exe"
Invoke-WebRequest -URI https://github.com/trilogy-group/cloudfix-linter-cloudformation/releases/tag/\${VERSION_TAG}/download/cloudfix-linter-cloudformation_\${PLATFORM}.exe -OutFile \$OUT_PATH_CFT
\$TEMP=\$OUT_PATH+"cloudfix-linter-cloudformation.exe"
Set-Alias -Name cloudfix-linter-cloudformation -Value \$TEMP -Scope Global
Write-Output "Cloudfix-linter installed successfully"


Write-Output "Installing cloudfix-linter-cloudformation........"
\$OUT_PATH_CFT=\$OUT_PATH+"mynewrule.py"
Invoke-WebRequest -URI https://github.com/trilogy-group/cloudfix-linter-cloudformation/releases/tag/\${VERSION_TAG}/download/mynewrule.py -OutFile \$OUT_PATH_CFT


# Installing CFN-Lint
pip install cfn-lint
EOF2