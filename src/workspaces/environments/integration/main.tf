resource "helm_release" "argocd" {
  namespace        = "argocd"
  create_namespace = true
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "v7.8.14"
  replace          = false
  force_update     = false
  timeout          = 600

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      name,
      repository,
      chart,
      version,
      namespace,
      create_namespace,
      values,
      set,
      set_sensitive,
      timeout,
      dependency_update,
      disable_webhooks,
      force_update,
      recreate_pods,
      replace,
      cleanup_on_fail,
      atomic,
      wait,
      wait_for_jobs,
      render_subchart_notes,
      verify,
      lint,
      max_history,
      disable_openapi_validation,
      postrender,
      skip_crds
    ]
  }
}
