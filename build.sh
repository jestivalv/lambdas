if [ "$#" -ne 1 ]; then
echo "Usage : ./build.sh lambdaName";
  exit 1;
fi

lambda=${1%/}; // Remove trailing slashes
echo "Deploying lambda";
cd $lambda;
if [ $? -eq 0 ]; then
  echo "...."
else
  echo "Couldn't cd to directory $lambda. Please check the spelling of the directory";
  exit 1
fi

echo "npm installing";
sudo npm install
if [ $? -eq 0 ]; then
  echo "done";
else
  echo "npm install failed";
fi

echo "Checking if aws-cli isn installed"
which aws
if [ $? -eq 0 ]; then
   echo "aws-cli is intalled, continuing "
else
  echo "You must install aws-cli first"
  exit 1
fi

echo "removing old zip file"
sudo rm index.zip;

echo "creating a new zip file"
zip index.zip * -r -x .git/\* \*.sh tests/\* node_modules/aws-sdk/\* \*.zip

echo "Uplading $lambda to $region"
sudo aws lambda create-function --function-name $lambda --runtime nodejs8.10 --role arn:aws:iam::873588644434:role/service-role/lambdaBasic --handler index.handler --zip-file fileb://index.zip --publish

if [ $? -eq 0 ]; then
   echo "create succesfull !!"
   exit 1;
fi

sudo aws lambda update-function-code --function-name $lambda --zip-file fileb://index.zip --publish
   
if [ $? -eq 0 ]; then
   echo "update succesfull !!"
   exit 1;
else
   echo "upload failed"
   echo "if the error was 400 check that there are not slashes in your lambda name"
   echo "Lambda name = $lambda"
fi
