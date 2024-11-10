# Deployment

```
aws --profile personal s3 sync --dryrun --exclude '.git/*' --exclude README.md . s3://paddlefish.net/lucy/
```

Then invalidate cloud formation

```
aws --profile personal cloudfront create-invalidation --distribution-id E8QT97BWVWYT3 --paths "/lucy/*"
```

# Development

```
python3 -m http.server
```
