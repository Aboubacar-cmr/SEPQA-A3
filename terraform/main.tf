# Spécifiction du provider
provider "aws" {
  region = "us-east-1"
}

# Création d'un role d'exécution des fonction lambda
resource "aws_iam_role" "role_lambdas" {
  # Définissez les autorisations nécessaires pour votre fonction Lambda
}


# S3 RESOUCE DATA SOURCE
resource "aws_s3_bucket" "bucket-source" {

  bucket = "data-source"
  
    tags = {
        ecole = "esgi",
        projet = "SEPQA",
        groupe = "A3"
    }

}

# Création d'un bucket s3 pour le stockage de données propres
# S3 RESOURCE DATA SINK 
resource "aws_s3_bucket" "bucket-sink" {
  bucket = "data-sink"

    tags = {
        ecole = "esgi",
        projet = "SEPQA",
        groupe = "A3"
    }
}



#-----------------------------------------LAMBDA EXTRACTION DATA GOUV-----------------------------------------------------------------------------------

# Création d'une fonction lambda planifié pour l'extraction des données dans data.gouv
# LAMBDA RESOURCE FUNCTION EXTRACTION DATA GOUVE
resource "aws_lambda" "lambda-extraction-data-gouve" {
    filename      = "zip/lambda_extractDataGouv.zip"
    function_name = "lambda-extractu-data-gouv"
    role          = aws_iam_role.ma_role.arn
    handler       = "extract.handler"
    runtime       = "python3.8"
}

# Création de la règle EventBridge pour la planification
resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name                = "mon_rule_schedule"
  description         = "Planification de l'exécution de la fonction Lambda"
  schedule_expression = "rate(1 day)"  # Par exemple, pour planifier une exécution quotidienne
}

# Configuration de la fonction Lambda comme cible de la règle EventBridge
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule_rule.name
  arn       = aws_lambda_function.ma_fonction_lambda.arn  # Remplacez par l'ARN de votre fonction Lambda
  target_id = "mon_target_lambda"
}


# Autorisation pour EventBridge d'invoquer la fonction Lambda
resource "aws_lambda_permission" "eventbridge_permission" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ma_fonction_lambda.function_name
  principal     = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.schedule_rule.arn
}

#-----------------------------------LAMBDA-TRANFORMATION-DATA SOURCE -----------------------------------------------------------------------------------------

# Création d'une fonction lambda planifier pour le traitement de données avant stockage dans le buckets s3
# LAMBDA FUNCTION TRANSFORMATION DATA
resource "aws_lambda" "lambda-extraction-data-gouve" {

    filename      = "zip/lambda_transform.zip"
    function_name = "lambda-transform-data-source"
    role          = aws_iam_role.ma_role.arn
    handler       = "transform.handler"
    runtime       = "python3.8"
}

# Création de la règle EventBridge pour la planification
resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name                = "mon_rule_schedule"
  description         = "Planification de l'exécution de la fonction Lambda"
  schedule_expression = "rate(1 day)"  # Par exemple, pour planifier une exécution quotidienne
}

# Configuration de la fonction Lambda comme cible de la règle EventBridge
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule_rule.name
  arn       = aws_lambda_function.ma_fonction_lambda.arn  # Remplacez par l'ARN de votre fonction Lambda
  target_id = "mon_target_lambda"
}


# Autorisation pour EventBridge d'invoquer la fonction Lambda
resource "aws_lambda_permission" "eventbridge_permission" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ma_fonction_lambda.function_name
  principal     = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.schedule_rule.arn
}

#-----------------------------------ATHENA SERVICE DATA-BASE-SOURCE-DATA-SINK ----------------------------------------------------------------------------------

# Création d'un service athena pour rendre accessible les données pour pour la restitution sur power BI
# ATHENA RESOURCE DATA BASE S3
resource "aws_athena_database" "athena-visualisation" {

  name = "data-base-s3"

}

#-----------------------------------SAGEMAKER SERVICE MODÉLISATION ----------------------------------------------------------------------------------

# Création d'un rôle IAM pour SageMaker
resource "aws_iam_role" "sagemaker_role" {
  name = "sagemaker-role"
  
   assume_role_policy= <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "sagemaker.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
    }
    EOF
}

# Attacher une politique IAM SageMaker au rôle
resource "aws_iam_role_policy_attachment" "sagemaker_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess" # ou une politique plus spécifique
  role       = aws_iam_role.sagemaker_role.name
}

# Création d'un modèle SageMaker
resource "aws_sagemaker_model" "mon_modele_sagemaker" {
  name       = "nom-de-votre-modele"
  execution_role_arn = aws_iam_role.sagemaker_role.arn
  
  primary_container {
    image = "votre-image-du-conteneur"
    model_data_url = "s3://chemin-vers-votre-modele" # URL vers le modèle stocké dans S3
  }
}


#----------------------------------LAMBDA FUNCITON SERVICE TRAINING MODELE FOR SAGEMAKER ----------------------------------------------------------------------------------

# Création d'une fonction lambda planifié pour l'entrainement du modèle de machine learning
# LAMBDA RESOURCE TRAINING MODLE
resource "aws_lambda" "lambda-training-ml" {
    
}
