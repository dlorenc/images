# DO NOT EDIT - this file is autogenerated by tfgen

output "summary" {
  value = merge(
    {
      basename(path.module) = {
        "ref"    = module.cassandra-reaper.image_ref
        "config" = module.cassandra-reaper.config
        "tags"   = ["latest"]
      }
  })
}

