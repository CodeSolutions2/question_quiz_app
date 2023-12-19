#!/bin/bash


# -------------------

export PROJECT_ID=$(echo "fit-union-378020")

export LOCATION=$(echo "europe-west9")
gcloud config set project $PROJECT_ID

export BUCKET_NAME=$(echo "question-quiz-data-examples")
export STORAGE_CLASS=STANDARD   # STANDARD, NEARLINE, COLDLINE, ARCHIVE

# -------------------

gcloud storage buckets create gs://$BUCKET_NAME --project=$PROJECT_ID --default-storage-class=STANDARD --location=$LOCATION --uniform-bucket-level-access

# -------------------

# List storage
# https://cloud.google.com/storage/docs/listing-objects
gcloud storage ls

# -------------------

# Create data files inside Q_Git
!echo 'git checkout|1. switch branches|2. reset the repo|3. save changes|4. nothing|1. switch branches' | tr "|" '\n' > test2.txt

!echo "Let's say we've made a mistake in our latest commit to a public branch. Which of the following commands is the best option for fixing our mistake?|1. git revert|2. git commit --amend|3. git reset|4. git checkout -- filename|1. git revert" | tr "|" '\n' > test3.txt

!echo 'Which of the following is true when you use the following command? git add -A|1. All new and updated files are staged|2. Files are staged in alphabetical order|3. All new files are staged|4. Only updated files are staged|1. All new and updated files are staged' | tr "|" '\n' > test4.txt

# -------------------


# Upload a data folder to a bucket
gcloud storage cp --recursive /home/j622amilah/Q_Git/ gs://$BUCKET_NAME/


# List the contents of a storage buckets
gcloud storage ls --recursive gs://$BUCKET_NAME/**

# ---------------------------------------------

# Make the bucket public for anyone to download

# Make all objects in a bucket publicly readable
# https://cloud.google.com/storage/docs/access-control/making-data-public#permissions-cli
gcloud storage buckets add-iam-policy-binding gs://$BUCKET_NAME --member=allUsers --role=roles/storage.objectViewer

# ---------------------------------------------

# Log into GCP on Kaggle

gcloud auth login --cred-file=key.json

# ---------------------------------------------

# gcloud storage cp --recursive gs://BUCKET_NAME/OBJECT_NAME SAVE_TO_LOCATION

# ---------------------------------------------
# Testing the program
# ---------------------------------------------

cat > run.py <<EOF
import os
from os import environ

import numpy as np

import PySimpleGUI as sg

from time import sleep

from fuzzywuzzy import fuzz
from fuzzywuzzy import process

import pandas as pd
pd.set_option('display.max_colwidth', 0)


sg.theme("reddit")

fpath = "/kaggle/working/Q_Git/"
listes_de_fichiers = os.listdir(fpath)

# ----------------------------------
# Parse the file names
tmp = sorted(listes_de_fichiers)
replace_le = ['test', '.txt']
replace_avec = ['', '']

tmp1 = []
for nom in tmp:
    for ind, i in enumerate(replace_le):
        nom = nom.replace(i, replace_avec[ind])
    tmp1.append(int(nom))
ordd = np.argsort(tmp1)

listes_de_fichiers_sort = [tmp[i] for i in ordd]
listes_de_fichiers_sort
# ----------------------------------

def clean_text(textout):
    to_replace = [";", '\n', '</p>', '<a', 'id=', "href=", 'title=', 'class=', '</a>', 
                  '</sup>', '<p>', '</b>', '<sup', '>', '<', '\\']
    replace_with = ''

    for ind, tr in enumerate(to_replace):
        textout = [i.replace(tr, replace_with) for i in textout]
    return textout
    
# ----------------------------------
cnt = 0
SCORE = 0
noms = ['QUESTION', 'REPONSE0', 'REPONSE1', 'REPONSE2', 'REPONSE3', 'ANSWER']
myres = 0

for ind, nom_de_fichier in enumerate(listes_de_fichiers_sort):
    
    # ----------------------------------
    # Lire des fichiers de mon PC
    # ----------------------------------
    filepath = os.path.join(fpath, nom_de_fichier)

    out = []
    with open(filepath, 'r') as reader:
        out.append(reader.read())
    out = out[0].split('\n')
    out = [i for i in out if any(i)]
    # ----------------------------------
    
    d = dict(zip(noms, out))
    
    if ind == len(listes_de_fichiers)-1:
        layout = [[sg.Text(f'Current SCORE: {SCORE}')], 
                  [sg.Text(d['QUESTION'])]]
    else:
        layout = [[sg.Text(f'Q{ind}, MY Current SCORE: {SCORE}')],
                  [sg.Multiline(d['QUESTION'], size=(40,10))],
              [sg.Button(d['REPONSE0'])],  
              [sg.Button(d['REPONSE1'])],
              [sg.Button(d['REPONSE2'])],
              [sg.Button(d['REPONSE3'])]]
    
    # Create the window
    window = sg.Window("DataLogger", layout, margins=(200, 200))
    
    event, values = window.read()
    
    if event == d['REPONSE0'] and d['ANSWER'] == d['REPONSE0']:  
        cnt = cnt + 1
        myres = d['REPONSE0']
    if event == d['REPONSE1'] and d['ANSWER'] == d['REPONSE1']:
        cnt = cnt + 1
        myres = d['REPONSE1']
    if event == d['REPONSE2'] and d['ANSWER'] == d['REPONSE2']:
        cnt = cnt + 1
        myres = d['REPONSE2']
    if event == d['REPONSE3'] and d['ANSWER'] == d['REPONSE3']:
        cnt = cnt + 1
        myres = d['REPONSE3']
        
    SCORE = cnt/(ind+1) * 100
    
    print('myres: ', myres)
    print('ANSWER: ', d['ANSWER'])
    print('---------------------------------------')
    
    if myres == 0:
        f = open("resultants.txt", "a")
        f.write(f"{d['QUESTION']}\n{myres}\n{d['ANSWER']}")
        f.write("\n\n")
        f.close()
        
    myres = 0
    window.close()


sleep(1)  # Wait 10 second
window.close()
# ----------------------------------
	EOF


# Installation:

# A. Check computer/Virtual Machine operating system
cat /etc/*-release
PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
NAME="Debian GNU/Linux"
VERSION_ID="11"
VERSION="11 (bullseye)"
VERSION_CODENAME=bullseye
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"

# B. version of python
# Type python --version OR python --v
# OR
# Go to /usr/lib and find the most recent version of python

# 0. Tinker for the OS
Ubuntu, Debian, other distros with Apt:
sudo apt-get install python3-tk
sudo apt-get remove python3-tk

Fedora:
sudo dnf install python3-tkinter

# OpenSUSE
sudo zypper install python39-tk  # to use tkinter for PySimpleGUI

# 1. python installations
sudo python3.9 -m pip install pysimplegui
sudo python3.9 -m pip install pandas
sudo python3.9 -m pip install fuzzywuzzy
sudo python3.9 -m pip install numpy

# 2. Run the program
python3 run.py

# 3. Clean up
sudo apt-get remove python3-tk
sudo python3.9 -m pip install pysimplegui
sudo python3.9 -m pip uninstall pandas
sudo python3.9 -m pip uninstall fuzzywuzzy
sudo python3.9 -m pip uninstall numpy




























# ./creer_des_resources.sh
# ./nettoyer_des_resources.sh 


# az login

# Save your login information to variables, and login by CLI
# export login=$(echo "j622amilah@gmail.com")   # <username>
# read -sp "Azure password: " password    # <password>
# az login -u $login -p $password

# ---------------------------------------------

export subscription_id=$(echo "425ecd08-433c-4c16-bcb0-f1ad27233c6d")

az account set -s $subscription_id

# ---------------------------------------------

# Generate a random number that allows you to easily identify which 
# resources belong together. 

# In general, you can keep track of all of your project resources because they are 
# grouped under the same Resource Group. But, I saw tutorials where a random number
# was used in addtion to group project objects.
export val=$(echo "X0")

if [[ $val == "X0" ]]
then 
    let "randomIdentifier=$RANDOM*$RANDOM"
       
else
    let "randomIdentifier=954709494"
fi

# ---------------------------------------------

# Créer Resource Group name

# Identify location name
export location=$(echo "francecentral")
# OU
# export location=$(echo "global") 

export val=$(echo "X0")

if [[ $val == "X0" ]]
then 

    export resourceGroupname=$(echo "gdr-name-$randomIdentifier")

    # Run the command below to see a list of location names for your area
    # az account list-locations -o table
    
    # Create a Resource Group
    az group create --name $resourceGroupname --location $location
       
else
    echo "Créer Resource Group : X1"
    export resourceGroupname=$(az group list | jq '.[].name' | tr -d '"' |cut -d $'\n' -f 2)
fi

# Lister des groupes de resources
az group list

# ---------------------------------------------

# Créer Compte de Stockage
export val=$(echo "X0")

if [[ $val == "X0" ]]
then 
    # Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only.
    export STORAGE_NAME=$(echo "storagename$randomIdentifier")

    # Create a Storage Account
    az storage account create --name $STORAGE_NAME \
                              --resource-group $resourceGroupname \
                              --location $location \
                              --kind StorageV2 \
                              --sku Standard_LRS \
                              --allow-blob-public-access true
        
    # ---------------------------------------------
    # Obtenir d'information important de compte de stockage
    # ---------------------------------------------
    # Obtenir le connection-string authorization de compte de stockage
    export ids=$(az storage account show -g $resourceGroupname -n $STORAGE_NAME | jq '.id')

    export connectionstring=$(az storage account show-connection-string -g $resourceGroupname -n $STORAGE_NAME | jq '.connectionString')
    # OU
    export connectionstring=$(az storage account show-connection-string -g $resourceGroupname -n $STORAGE_NAME --query connectionString)

    # Lister des comptes de stockage
    az storage account list -g $resourceGroupname

    # Imprimer des clés de stockage
    az storage account keys list -g $resourceGroupname -n $STORAGE_NAME

    # Enregister le premiere clé de compte de stockage 
    export STORAGE_ACCOUNT_KEY=$(az storage account keys list -g $resourceGroupname -n $STORAGE_NAME | jq '.[].value' |cut -d $'\n' -f 1)

    # destination =  https://storagename879395520.file.core.windows.net/
    export destination=$(az storage account show -g $resourceGroupname -n $STORAGE_NAME | jq '.primaryEndpoints.file')
    
    # Verifier que le compte de stockage a access publique
    # https://learn.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-configure?tabs=azure-cli
    az storage account show \
    --name <storage-account> \
    --resource-group <resource-group> \
    --query allowBlobPublicAccess \
    --output tsv
       
else
    echo "Créer Compte de Stockage : X1"
    export STORAGE_NAME=$(az storage account list -g $resourceGroupname | jq -r '.[].name')
    export ids=$(az storage account show -g $resourceGroupname -n $STORAGE_NAME | jq '.id')
    export connectionstring=$(az storage account show-connection-string -g $resourceGroupname -n $STORAGE_NAME --query connectionString)
    export STORAGE_ACCOUNT_KEY=$(az storage account keys list -g $resourceGroupname -n $STORAGE_NAME | jq '.[].value' |cut -d $'\n' -f 1)
    export destination=$(az storage account show -g $resourceGroupname -n $STORAGE_NAME | jq '.primaryEndpoints.file')
fi

# ---------------------------------------------



# ---------------------------------------------------------
# Créer fichiers partage
# https://learn.microsoft.com/fr-fr/azure/storage/files/storage-how-to-use-files-portal?tabs=azure-cli
# ---------------------------------------------------------
export shareName=$(echo "fichiershare-$randomIdentifier")
export directoryName=$(echo "directory-$randomIdentifier")

export val=$(echo "X0")

if [[ $val == "X0" ]]
then 
    # An Azure file share is a convenient place for cloud applications to write their logs, metrics, and crash dumps. Logs can be written by the application instances via the File REST API, and developers can access them by mounting the file share on their local machine.

    # On a forcé télécharger des fichiers au partage de fichiers
    az storage share-rm create --storage-account $STORAGE_NAME \
        --name $shareName \
        --quota 1024 \
        --enabled-protocols SMB \
        --output none


    # Créer un répertoire nommé myDirectory à la racine de votre partage de fichiers Azure
    az storage directory create \
       --account-name $STORAGE_NAME \
       --share-name $shareName \
       --name $directoryName \
       --output none \
       --connection-string $connectionstring
       
else
    echo "Créer fichiers partage : X1"
fi




# ---------------------------------------------------------
# Charger (Upload) un fichier
# ---------------------------------------------------------
export val=$(echo "X0")

if [[ $val == "X0" ]]
then 
    # Il faut etre dans le meme directory que le fichier 
    cd /home/oem2/Documents/PROGRAMMING/Github_analysis_PROJECTS/Créer_des_questionnaires/Q_Azure

    path_sur_Azure=$(echo "${directoryName}/out0.txt")  # vous mettez le nom de fichier meme s'il n'exist pas sur le serveur
    path_sur_PC_wrt_terminal=$(echo "out0.txt")

    az storage file upload \
        --account-name $STORAGE_NAME \
        --share-name $shareName \
        --source $path_sur_PC_wrt_terminal \
        --path $path_sur_Azure \
        --connection-string $connectionstring

    # az storage file upload --account-name mystorageaccount \
    #                        --account-key $STORAGE_ACCOUNT_KEY \
    #                        --share-name myfileshare \
    #                        --path "myDirectory/index.php" \
    #                        --source "/home/scrapbook/tutorial/php-docs-hello-world/index.php"
    
    az storage file list --account-name $STORAGE_NAME --share-name $shareName --path $path_sur_Azure --output table --connection-string $connectionstring
    
else
    echo "Charger (Upload) un fichier : X1"
fi




# ---------------------------------------------------------
# Charger (Upload) une ensemble des fichiers
# ---------------------------------------------------------
export val=$(echo "X0")

if [[ $val == "X0" ]]
then 
    # Avec le terminal, il faut être dans le fichier ou vous voulez charger
    cd /home/oem2/Documents/PROGRAMMING/Github_analysis_PROJECTS/Créer_des_questionnaires/Q_Azure

    dest_path_sur_Azure=$(echo "${shareName}/${directoryName}")
    dir_path_sur_PC_wrt_terminal=$(echo ".")

    az storage file upload-batch \
        --account-name $STORAGE_NAME \
        --destination $dest_path_sur_Azure \
        --source $dir_path_sur_PC_wrt_terminal \
        --connection-string $connectionstring
    #   --account-key $STORAGE_ACCOUNT_KEY
else
    echo "Charger (Upload) une ensemble des fichiers : X1"
fi



# ---------------------------------------------------------
# Téléchargement d'un fichier
# ---------------------------------------------------------
# Delete an existing file by the same name as SampleDownload.txt, if it exists, because you've run this example before
# rm -f SampleDownload.txt
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
    cd /home/oem2/Documents/PROGRAMMING/Github_analysis_PROJECTS/Créer_des_questionnaires
    destpath_sur_PC_wrt_terminal=$(echo ".")

    az storage file download \
        --account-name $STORAGE_NAME \
        --share-name $shareName \
        --path $path_sur_Azure \
        --dest $destpath_sur_PC_wrt_terminal \
        --output none
else
    echo "Téléchargement d'un fichier : X1"
fi


# ---------------------------------------------------------
# Supprimer des fichier de - ne fonctionne pas
# ---------------------------------------------------------
export val=$(echo "X1")

if [[ $val == "X0" ]]
then 
    # Avec le terminal, il faut être dans le fichier ou vous voulez charger
    cd /home/oem2/Documents/PROGRAMMING/Github_analysis_PROJECTS/Créer_des_questionnaires/Q_Azure

    dest_path_sur_Azure=$(echo "${shareName}/${directoryName}")
    dir_path_sur_PC_wrt_terminal=$(echo ".")

    az storage file delete-batch \
            --source $dir_path_sur_PC_wrt_terminal \
            --connection-string $connectionstring \
            --pattern '[*.txt]*' 

else
    echo "Charger (Upload) une ensemble des fichiers : X1"
fi

