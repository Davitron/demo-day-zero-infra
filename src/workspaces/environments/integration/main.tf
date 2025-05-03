resource "helm_release" "argocd" {
  namespace        = ""
  create_namespace = true
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd"
  version          = "v7.8.14"
  replace          = false
  force_update     = false
  timeout          = 600

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      namespace,
      create_namespace,
      name,
      repository,
      chart,
      version,
      replace,
      force_update,
      timeout,
      values,
      set,
      metadata,
      annotations,
      labels,
      max_history,
      wait,
      wait_for_jobs,
      dependency_update,
      atomic,
      disable_webhooks,
      lint,
      render_subchart_notes,
      reset_values,
      reuse_values,
      skip_crds,
      verify,
      disable_openapi_validation
    ]
  }
}
