resource "aws_iam_user" "streamlit_user" {
  name = "streamlit-athena-user"
}

resource "aws_iam_user_policy_attachment" "user_policy_attach" {
  user       = aws_iam_user.streamlit_user.name
  policy_arn = aws_iam_policy.athena_query_policy.arn
}

resource "aws_iam_access_key" "streamlit_user_key" {
  user = aws_iam_user.streamlit_user.name
}

output "access_key_id" {
  value     = aws_iam_access_key.streamlit_user_key.id
  sensitive = true
}

output "secret_access_key" {
  value     = aws_iam_access_key.streamlit_user_key.secret
  sensitive = true
}
