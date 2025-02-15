test_that("diagnose_LD_mismatch_susie works", {

  LD_map <- readRDS(system.file("extdata/sample_data", "LDL_example.LD_map.RDS", package = "ctwas"))
  skip_if_no_LD_file(LD_map$LD_file)

  gwas_n <- 343621
  z_snp <- readRDS(system.file("extdata/sample_data", "LDL_example.preprocessed.z_snp.RDS", package = "ctwas"))
  z_gene <- readRDS(system.file("extdata/sample_data", "LDL_example.z_gene.RDS", package = "ctwas"))
  weights <- readRDS(system.file("extdata/sample_data", "LDL_example.preprocessed.weights.RDS", package = "ctwas"))

  ctwas_res <- readRDS(system.file("extdata/sample_data", "LDL_example.ctwas_sumstats_res.RDS", package = "ctwas"))
  finemap_res <- ctwas_res$finemap_res

  precomputed_LD_diagnosis_res <- readRDS("LDL_example.LD_diagnosis_res.RDS")

  capture.output({
    set.seed(99)
    nonSNP_PIPs <- compute_region_nonSNP_PIPs(finemap_res)
    selected_region_ids <- names(nonSNP_PIPs[nonSNP_PIPs > 0.8])

    LD_diagnosis_res <- diagnose_LD_mismatch_susie(z_snp,
                                                   selected_region_ids,
                                                   LD_map,
                                                   gwas_n)

    problematic_snps <- LD_diagnosis_res$problematic_snps
    flipped_snps <- LD_diagnosis_res$flipped_snps
    condz_stats <- LD_diagnosis_res$condz_stats
  })

  expect_equal(length(problematic_snps), 0)
  expect_equal(LD_diagnosis_res, precomputed_LD_diagnosis_res)

})

