
#' @title Harmonizes z scores from GWAS to match LD reference genotypes.
#' Flips signs when reverse complement matches, and removes strand ambiguous SNPs
#'
#' @param z_snp a data frame, with columns "id", "A1", "A2" and "z".
#'     Z scores for every SNP. "A1" is the effect allele.
#'
#' @param snp_info a data frame of SNP info for the reference,
#' with columns "chrom", "id", "pos", "alt", "ref".
#'
#' @param drop_strand_ambig TRUE/FALSE, if TRUE remove strand ambiguous variants (A/T, G/C).
#'
#' @return a data frame, z_snp with the "z" columns flipped to match LD reference.
#'
#' @importFrom logging loginfo
#' @importFrom data.table rbindlist
#'
#' @keywords internal
#'
harmonize_z <- function(z_snp, snp_info, drop_strand_ambig = TRUE){

  # Check LD reference SNP info
  target_header <- c("chrom", "id", "pos", "alt", "ref")
  if (!all(target_header %in% colnames(snp_info))){
    stop("snp_info needs to contain the following columns: ",
         paste(target_header, collapse = " "))
  }

  snpnames <- intersect(z_snp$id, snp_info$id)
  loginfo("Harmonize %s variants in both GWAS and LD reference", length(snpnames))

  if (length(snpnames) != 0) {
    z.idx <- match(snpnames, z_snp$id)
    ld.idx <- match(snpnames, snp_info$id)
    qc <- allele.qc(z_snp[z.idx,]$A1, z_snp[z.idx,]$A2, snp_info[ld.idx,]$alt, snp_info[ld.idx,]$ref)
    ifflip <- qc[["flip"]]
    ifremove <- !qc[["keep"]]
    flip.idx <- z.idx[ifflip]
    z_snp[flip.idx, c("A1", "A2")] <- z_snp[flip.idx, c("A2", "A1")]
    z_snp[flip.idx, "z"] <- -z_snp[flip.idx, "z"]
    loginfo("Flip signs for %s (%.2f%%) variants", length(flip.idx), length(flip.idx)/length(z.idx)*100)

    if (isTRUE(drop_strand_ambig) & any(ifremove)) {
      remove.idx <- z.idx[ifremove]
      z_snp <- z_snp[-remove.idx, , drop = FALSE]
      loginfo("Remove %s strand ambiguous variants", length(remove.idx))
    }
  }
  return(z_snp)
}

#' Harmonize weight to match LD reference genotypes.
#' Flip signs when reverse complement matches, remove ambiguous variants from the prediction models
#'
#' @param wgt.matrix a matrix of the weights
#'
#' @param snps a data frame of the weight variants
#' with columns "chrom", "id", "cm", "pos", "alt", "ref". "alt" is the effect allele.
#'
#' @param snp_info a data frame of SNP info for the reference,
#'  with columns "chrom", "id", "pos", "alt", "ref".
#'
#' @param drop_strand_ambig TRUE/FALSE, if TRUE remove strand ambiguous variants (A/T, G/C).
#'
#' @return wgt.matrix and snps with alleles flipped to match
#
#' @importFrom data.table rbindlist
#'
#' @keywords internal
#'
harmonize_weights <- function (wgt.matrix, snps, snp_info, drop_strand_ambig = TRUE){

  # Check LD reference SNP info
  target_header <- c("chrom", "id", "pos", "alt", "ref")
  if (!all(target_header %in% colnames(snp_info))){
    stop("snp_info needs to contain the following columns: ",
         paste(target_header, collapse = " "))
  }

  snps <- snps[match(rownames(wgt.matrix), snps$id), ]
  snpnames <- intersect(snps$id, snp_info$id)

  if (length(snpnames) != 0) {
    snps.idx <- match(snpnames, snps$id)
    ld.idx <- match(snpnames, snp_info$id)
    qc <- allele.qc(snps[snps.idx,]$alt, snps[snps.idx,]$ref, snp_info[ld.idx,]$alt, snp_info[ld.idx,]$ref)
    ifflip <- qc[["flip"]]
    ifremove <- !qc[["keep"]]
    flip.idx <- snps.idx[ifflip]
    snps[flip.idx, c("alt", "ref")] <- snps[flip.idx, c("ref", "alt")]
    wgt.matrix[flip.idx, ] <- -wgt.matrix[flip.idx, ]

    if (drop_strand_ambig && any(ifremove)){
      # if dropping ambiguous variants, or >2 ambiguous variants and 0 unambiguous variants,
      # discard the ambiguous variants
      remove.idx <- snps.idx[ifremove]
      snps <- snps[-remove.idx, , drop = FALSE]
      wgt.matrix <- wgt.matrix[-remove.idx, , drop = FALSE]
    }
  }
  return(list(wgt.matrix = wgt.matrix, snps = snps))
}

# flip alleles
# Copied from allele.qc function
# in https://github.com/gusevlab/fusion_twas/blob/master/FUSION.assoc_test.R,
allele.qc <- function(a1,a2,ref1,ref2) {
  a1 = toupper(a1)
  a2 = toupper(a2)
  ref1 = toupper(ref1)
  ref2 = toupper(ref2)

  ref = ref1
  flip = ref
  flip[ref == "A"] = "T"
  flip[ref == "T"] = "A"
  flip[ref == "G"] = "C"
  flip[ref == "C"] = "G"
  flip1 = flip

  ref = ref2
  flip = ref
  flip[ref == "A"] = "T"
  flip[ref == "T"] = "A"
  flip[ref == "G"] = "C"
  flip[ref == "C"] = "G"
  flip2 = flip

  snp = list()
  snp[["keep"]] = !((a1=="A" & a2=="T") | (a1=="T" & a2=="A") | (a1=="C" & a2=="G") | (a1=="G" & a2=="C"))
  snp[["flip"]] = (a1 == ref2 & a2 == ref1) | (a1 == flip2 & a2 == flip1)

  return(snp)
}
