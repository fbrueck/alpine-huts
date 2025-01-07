resource "aws_iam_role" "step_function_role" {
    name = "${local.ingestion_prefix}_step_function_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "states.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy" "step_function_policy" {
    name = "${local.ingestion_prefix}_step_function_policy"
    role = aws_iam_role.step_function_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "lambda:InvokeFunction",
                    "glue:StartCrawler",
                    "glue:GetCrawler"
                ]
                Effect = "Allow"
                Resource = "*"
            }
        ]
    })
}

resource "aws_sfn_state_machine" "alpine_huts_ingestion_orchestration" {
    name     = "${local.ingestion_prefix}_orchestration"
    role_arn = aws_iam_role.step_function_role.arn

    definition = jsonencode({
        Comment: "Runs the ingestion process for the Alpine Huts dataset",
        StartAt: "InvokeLambda",
        States: {
            InvokeLambda: {
                Type: "Task",
                Resource: aws_lambda_function.alpine_huts_ingestion.arn,
                Next: "StartGlueCrawler"
            },
        StartGlueCrawler: {
          Type: "Task",
          Parameters: {
            Name: aws_glue_crawler.raw_alpine_huts.name
          },
          Resource: "arn:aws:states:eu-central-1:${local.account_id}:aws-sdk:glue:startCrawler",
          Next: "CrawlerInfo",
          Retry: [
            {
              ErrorEquals: [
                "States.ALL"
              ],
              BackoffRate: 2,
              IntervalSeconds: 10,
              MaxAttempts: 2
            }
          ]
        },
        CrawlerInfo: {
          Type: "Task",
          Next: "CrawlerStatus",
          Parameters: {
            Name: aws_glue_crawler.raw_alpine_huts.name
          },
          Resource: "arn:aws:states:::aws-sdk:glue:getCrawler",
          Retry: [
            {
              ErrorEquals: [
                "States.ALL"
              ],
              BackoffRate: 2,
              IntervalSeconds: 10,
              MaxAttempts: 2
            }
          ]
        },
        CrawlerStatus: {
          Type: "Choice",
          Choices: [
            {
              Variable: "$.Crawler.State",
              StringEquals: "FAILED",
              Next: "CrawlerFailed"
            },
            {
              Variable: "$.Crawler.State",
              StringEquals: "RUNNING",
              Next: "CrawlerFinishWait"
            },
            {
              Variable: "$.Crawler.State",
              StringEquals: "STOPPING",
              Next: "CrawlerFinishWait"
            },
            {
              Variable: "$.Crawler.State",
              StringEquals: "READY",
              Next: "Success"
            }
          ],
          Default: "CrawlerFailed"
        },
        CrawlerFinishWait: {
          Type: "Wait",
          Seconds: 10,
          Next: "CrawlerInfo"
        },
        CrawlerFailed: {
          Type: "Fail"
        },
        Success: {
          Type: "Succeed"
        },

        }
    })
}

resource "aws_cloudwatch_event_rule" "daily_trigger" {
    name                = "${local.ingestion_prefix}_daily_trigger"
    schedule_expression = "cron(0 18 * * ? *)"
}

resource "aws_cloudwatch_event_target" "step_function_target" {
    rule      = aws_cloudwatch_event_rule.daily_trigger.name
    arn       = aws_sfn_state_machine.alpine_huts_ingestion_orchestration.arn
    role_arn  = aws_iam_role.cloudwatch_invoke_step_function.arn
}

resource "aws_iam_role" "cloudwatch_invoke_step_function" {
  name = "${local.ingestion_prefix}-cloudwatch_invoke_step_function"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "invoke_step_function_policy" {
  name        = "${local.ingestion_prefix}-invoke_step_function_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "states:StartExecution",
        Resource = aws_sfn_state_machine.alpine_huts_ingestion_orchestration.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.cloudwatch_invoke_step_function.name
  policy_arn = aws_iam_policy.invoke_step_function_policy.arn
}
